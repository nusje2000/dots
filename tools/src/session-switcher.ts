#!/usr/bin/env bun
// Tmux session switcher (fzf UI, Bun orchestrator).
//
// fzf opens instantly with the local data (session + branch). The slow context
// — Linear issue (title + workflow state) and GitHub PR (review + CI status) —
// is fetched concurrently in the background and shown as coloured [ text ]
// badges. Each row shows a spinner where a badge is still loading, then fills in
// place. Updates are pushed to the running fzf via its --listen HTTP API
// (reload), and --track keeps the cursor put across updates.

import { readFileSync, writeFileSync, unlinkSync } from "node:fs";
import { join, resolve } from "node:path";
import { tmpdir } from "node:os";
import { run, openUrl } from "./shared/proc.ts";
import { sanitize } from "./shared/cache.ts";
import {
  RESET, YELLOW, DIM, C_GREEN, C_RED, C_AMBER, C_BLUE, C_GRAY,
  SPINNER, badge, visibleLen, fg, colorFromKey,
} from "./shared/ansi.ts";
import {
  linearKey, linearIdentifier, fetchLinear, cachedLinear, type LinearInfo,
} from "./shared/linear.ts";
import {
  hasGh, fetchPrByBranch, cachedPrByBranch, type PrInfo,
} from "./shared/github.ts";

const CONCURRENCY = 8;
const TICK_MS = 120;

type Row = {
  session: string;
  path: string;
  branch: string;
  color: string;
  dirty: number;   // tracked files with uncommitted changes (untracked excluded)
  ahead: number;   // commits not yet pushed to the upstream
  isCurrent: boolean;
  linearState: "pending" | "done";
  linear: LinearInfo | null;
  prState: "pending" | "done";
  pr: PrInfo | null;
};

// --- data sources -----------------------------------------------------------
async function gitBranch(dir: string): Promise<string> {
  const head = await run(["git", "-C", dir, "symbolic-ref", "--quiet", "--short", "HEAD"]);
  if (head.ok && head.stdout.trim()) return head.stdout.trim();
  const detached = await run(["git", "-C", dir, "rev-parse", "--short", "HEAD"]);
  return detached.ok ? detached.stdout.trim() : "";
}

// Local working-state counts: tracked files with uncommitted changes (untracked
// deliberately excluded) and commits ahead of the branch's upstream. Both are 0
// when there's no repo / no upstream.
async function gitStatus(dir: string): Promise<{ dirty: number; ahead: number }> {
  const status = await run(["git", "-C", dir, "status", "--porcelain", "--untracked-files=no"]);
  const dirty = status.ok ? status.stdout.split("\n").filter(Boolean).length : 0;
  const ahead = await run(["git", "-C", dir, "rev-list", "--count", "@{upstream}..HEAD"]);
  return { dirty, ahead: ahead.ok ? parseInt(ahead.stdout.trim(), 10) || 0 : 0 };
}

// The key that groups sessions into the same "project". git's common dir is
// shared by every linked worktree of a repo, so worktree siblings collapse to
// one colour; non-repo paths just group by their own path.
async function projectKey(dir: string): Promise<string> {
  const common = await run(["git", "-C", dir, "rev-parse", "--git-common-dir"]);
  if (common.ok && common.stdout.trim()) return resolve(dir, common.stdout.trim());
  return dir;
}

// --- badges -----------------------------------------------------------------
function reviewBadges(pr: PrInfo): string[] {
  const out: string[] = [];
  if (pr.approvals > 0) out.push(badge(C_GREEN, `✓ ${pr.approvals}`));
  if (pr.changes > 0) out.push(badge(C_RED, `✗ ${pr.changes}`));
  // No reviews yet: [ PR ], grey when draft, blue otherwise.
  if (out.length === 0) out.push(badge(pr.draft ? C_GRAY : C_BLUE, "PR"));
  return out;
}
function ciBadge(ci: NonNullable<PrInfo["ci"]>): string {
  if (ci === "PASS") return badge(C_GREEN, "✓ CI");
  if (ci === "FAIL") return badge(C_RED, "✗ CI");
  return badge(C_AMBER, "● CI");
}

// --- rendering --------------------------------------------------------------
// Local git state, shown between the branch and the remote badges: uncommitted
// tracked changes (blue) and unpushed commits (green). The unpushed marker is a
// Nerd Font glyph from the stable Font Awesome range (nf-fa-arrow_up).
const ICON_DIRTY = "~";
const ICON_AHEAD = ""; //
function gitSegment(r: Row): string {
  const parts: string[] = [];
  if (r.dirty > 0) parts.push(fg(C_BLUE, `${ICON_DIRTY} ${r.dirty}`));
  if (r.ahead > 0) parts.push(fg(C_GREEN, `${ICON_AHEAD} ${r.ahead}`));
  return parts.join(" ");
}

function badgesFor(r: Row, frame: number, linearW: number): string {
  const spin = `${DIM}${SPINNER[frame % SPINNER.length]}${RESET}`;
  const parts: string[] = [];
  if (r.linearState === "pending") parts.push(spin);
  else if (r.linear) parts.push(badge(r.linear.stateColor, r.linear.stateName.padEnd(linearW)));
  if (r.prState === "pending") parts.push(spin);
  else if (r.pr) {
    parts.push(...reviewBadges(r.pr));
    if (r.pr.ci) parts.push(ciBadge(r.pr.ci));
  }
  return parts.join(" ");
}

function render(rows: Row[], frame: number): string {
  const sessionW = Math.max(...rows.map((r) => r.session.length));
  const branchW = Math.max(0, ...rows.map((r) => r.branch.length));
  // Uniform width for every Linear status badge: pad each state name to the
  // widest resolved one so the badges line up.
  const linearW = Math.max(0, ...rows.filter((r) => r.linearState === "done" && r.linear).map((r) => r.linear!.stateName.length));
  const gitSegs = rows.map(gitSegment);
  const gitW = Math.max(0, ...gitSegs.map(visibleLen));
  const badges = rows.map((r) => badgesFor(r, frame, linearW));
  const badgeW = Math.max(0, ...badges.map(visibleLen));

  return rows
    .map((r, i) => {
      const marker = r.isCurrent ? "*" : " ";
      let line = `${fg(r.color, "█")} ${marker} ${r.session.padEnd(sessionW)}`;
      if (r.branch) {
        line += `  ${YELLOW}${r.branch.padEnd(branchW)}${RESET}`;
        if (gitW > 0) {
          const g = gitSegs[i];
          line += `  ${g}${" ".repeat(gitW - visibleLen(g))}`;
        }
        if (badgeW > 0) {
          const b = badges[i];
          line += `  ${b}${" ".repeat(badgeW - visibleLen(b))}`;
        }
        const title = r.linearState === "done" && r.linear?.title ? `${DIM}${r.linear.title}${RESET}` : "";
        if (title) line += `  ${title}`;
      }
      // Hidden trailing fields (not displayed via --with-nth) carry the URLs the
      // space binding opens: session \t line \t linear \t github \t ci.
      return `${r.session}\t${line}\t${r.linear?.url ?? ""}\t${r.pr?.url ?? ""}\t${r.pr?.ciUrl ?? ""}`;
    })
    .join("\n");
}

// --- open-target submenu (subcommand) ---------------------------------------
// Invoked as `… session-switcher menu <linearUrl> <githubUrl> <ciUrl>` from fzf's
// space binding. Offers a chooser over the non-empty targets and opens the pick;
// a single available target opens straight away.
async function runOpenMenu(argv: string[]) {
  const labels = ["Linear issue", "GitHub PR", "CI build"];
  const options = argv.map((url, i) => ({ label: labels[i], url })).filter((o) => o.url);
  if (options.length === 0) {
    await run(["tmux", "display-message", "No links for this session yet."]);
    return;
  }
  let chosen = options[0];
  if (options.length > 1) {
    const menu = Bun.spawn(["fzf", "--prompt=open > ", "--no-info", "--height=~100%"],
      { stdin: "pipe", stdout: "pipe", stderr: "inherit" });
    menu.stdin.write(options.map((o) => o.label).join("\n"));
    menu.stdin.end();
    const picked = (await new Response(menu.stdout).text()).split("\n")[0]?.trim();
    await menu.exited;
    const match = options.find((o) => o.label === picked);
    if (!match) return;
    chosen = match;
  }
  await openUrl(chosen.url);
}

if (process.argv[2] === "menu") {
  await runOpenMenu(process.argv.slice(3));
  process.exit(0);
}

// --- main -------------------------------------------------------------------
const currentSession = (await run(["tmux", "display-message", "-p", "#S"])).stdout.trim();
const listing = (await run(["tmux", "list-sessions", "-F", "#{session_name}\t#{pane_current_path}"])).stdout;
const entries = listing
  .split("\n")
  .filter(Boolean)
  .map((l) => { const [s, p] = l.split("\t"); return { session: s, path: p }; });

if (entries.length === 0) {
  await run(["tmux", "display-message", "No tmux sessions found."]);
  process.exit(0);
}

const key = linearKey();
const gh = hasGh();
const branches = await Promise.all(entries.map((e) => gitBranch(e.path)));
const colors = await Promise.all(entries.map((e) => projectKey(e.path).then(colorFromKey)));
const gitStatuses = await Promise.all(entries.map((e) => gitStatus(e.path)));

// Build rows, resolving anything already cached so only true misses spin.
const rows: Row[] = entries.map((e, i) => {
  const branch = branches[i];

  let linearState: "pending" | "done" = "done";
  let linear: LinearInfo | null = null;
  const id = branch ? linearIdentifier(branch) : null;
  if (id && key) {
    const cached = cachedLinear(id);
    if (cached === undefined) linearState = "pending";
    else linear = cached;
  }

  let prState: "pending" | "done" = "done";
  let pr: PrInfo | null = null;
  if (branch && gh) {
    const cached = cachedPrByBranch(e.path, branch);
    if (cached === undefined) prState = "pending";
    else pr = cached;
  }

  return { session: e.session, path: e.path, branch, color: colors[i],
    dirty: gitStatuses[i].dirty, ahead: gitStatuses[i].ahead,
    isCurrent: e.session === currentSession, linearState, linear, prState, pr };
});

const currentIndex = rows.findIndex((r) => r.isCurrent) + 1; // 1-based, 0 if absent

// Launch fzf with the instant list; it exposes its --listen port via a file.
// ctrl-x writes the highlighted session to killFile, which the loop below acts
// on (Bun owns the state, so the kill must round-trip through it).
const portFile = join(tmpdir(), `ss_port_${process.pid}`);
const renderFile = join(tmpdir(), `ss_render_${process.pid}`);
const killFile = join(tmpdir(), `ss_kill_${process.pid}`);
try { unlinkSync(portFile); } catch {}
try { unlinkSync(killFile); } catch {}

const dispatcher = join(import.meta.dir, "..", "launch.sh");
const fzfArgs = [
  "--ansi", "--delimiter=\t", "--with-nth=2", "--no-sort", "--track",
  "--prompt=switch session > ", "--header=enter: switch    space: open links    ctrl-x: kill session    ctrl-d: detach",
  "--bind=ctrl-j:down,ctrl-k:up,ctrl-u:half-page-up",
  `--bind=start:execute-silent(echo $FZF_PORT > ${portFile})`,
  `--bind=ctrl-x:execute-silent(echo {1} >> ${killFile})`,
  "--bind=ctrl-d:execute-silent(tmux detach-client)+abort",
  `--bind=space:execute('${dispatcher}' session-switcher menu {3} {4} {5})`,
  "--listen",
];
if (currentIndex > 0) fzfArgs.push(`--bind=load:pos(${currentIndex})+unbind(load)`);

const fzf = Bun.spawn(["fzf", ...fzfArgs], { stdin: "pipe", stdout: "pipe", stderr: "inherit" });
fzf.stdin.write(render(rows, 0));
fzf.stdin.end();

// Wait (briefly) for fzf to report its listen port.
let port = "";
for (let i = 0; i < 100 && !port; i++) {
  try { port = readFileSync(portFile, "utf8").trim(); } catch {}
  if (!port) await Bun.sleep(30);
}

const pending = () => rows.filter((r) => r.linearState === "pending" || r.prState === "pending").length;

async function pushRender(frame: number) {
  if (!port) return;
  writeFileSync(renderFile, render(rows, frame));
  try {
    await fetch(`http://127.0.0.1:${port}`, { method: "POST", body: `reload(cat '${renderFile}')` });
  } catch { /* fzf may have exited */ }
}

// A single serialized loop, alive for as long as fzf is: it processes kill
// requests, animates spinners, and picks up resolved rows. It only re-renders
// when something actually changed, so an idle list causes no traffic.
let frame = 0;
let posting = false;
let reopening = false;
let prevPending = pending();

// Killing the current session can't be done while the popup is attached to it,
// so hand it to a detached server-side job: once this popup closes, it switches
// the client to the session below (fallback: above), kills the old one, and
// reopens the switcher there.
function scheduleReopenAfterKill(cur: string) {
  if (reopening) return;
  const idx = rows.findIndex((r) => r.session === cur);
  const below = rows[idx + 1]?.session ?? rows[idx - 1]?.session;
  if (!below) return; // only one session left — nothing to switch to
  reopening = true;
  const chain =
    `sleep 0.3; tmux switch-client -t '${below}'; tmux kill-session -t '${cur}'; ` +
    `tmux display-popup -E -w 80% -h 60% -T ' Tmux sessions ' '${dispatcher}' session-switcher`;
  run(["tmux", "run-shell", "-b", chain]);
  try { fzf.kill(); } catch {} // close this popup so the chain can take over
}

async function drainKills(): Promise<boolean> {
  let content: string;
  try { content = readFileSync(killFile, "utf8"); } catch { return false; }
  try { unlinkSync(killFile); } catch {}
  let changed = false;
  for (const target of content.split("\n").map((s) => s.trim()).filter(Boolean)) {
    if (target === currentSession) { scheduleReopenAfterKill(target); continue; }
    await run(["tmux", "kill-session", "-t", target]);
    const idx = rows.findIndex((r) => r.session === target);
    if (idx >= 0) { rows.splice(idx, 1); changed = true; }
  }
  return changed;
}
const ticker = port
  ? setInterval(async () => {
      if (posting) return;
      posting = true;
      try {
        let dirty = await drainKills();
        const p = pending();
        if (p > 0) { frame++; dirty = true; }
        // The final tick where pending drops to 0 must still push once, or the
        // last-drawn spinner freezes in place of the resolved badge.
        if (p !== prevPending) dirty = true;
        prevPending = p;
        if (dirty) await pushRender(frame);
      } finally { posting = false; }
    }, TICK_MS)
  : null;

// Fire the fetches concurrently (fire-and-forget; the ticker surfaces results).
(async () => {
  const targets = rows.filter((r) => r.branch && (r.linearState === "pending" || r.prState === "pending"));
  let idx = 0;
  const workers = Array.from({ length: Math.min(CONCURRENCY, targets.length) }, async () => {
    while (idx < targets.length) {
      const r = targets[idx++];
      const jobs: Promise<void>[] = [];
      if (r.linearState === "pending") {
        const id = linearIdentifier(r.branch)!;
        jobs.push(fetchLinear(id, key).then((v) => { r.linear = v; r.linearState = "done"; }));
      }
      if (r.prState === "pending") {
        jobs.push(fetchPrByBranch(r.path, r.branch).then((v) => { r.pr = v; r.prState = "done"; }));
      }
      await Promise.all(jobs);
    }
  });
  await Promise.all(workers);
})();

// Block on the user's choice, then switch.
const selection = await new Response(fzf.stdout).text();
await fzf.exited;
if (ticker) clearInterval(ticker);
try { unlinkSync(portFile); } catch {}
try { unlinkSync(renderFile); } catch {}
try { unlinkSync(killFile); } catch {}

const chosen = selection.split("\n")[0]?.split("\t")[0]?.trim();
if (chosen) await run(["tmux", "switch-client", "-t", chosen]);
process.exit(0);
