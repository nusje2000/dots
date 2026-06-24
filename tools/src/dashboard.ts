#!/usr/bin/env bun
// Tmux PR/issue dashboard (fzf UI, Bun orchestrator).
//
// A prefix-key popup that surfaces what needs your attention across GitHub and
// Linear, in three sections: things requiring action (review requests + your own
// PRs with failing CI or requested changes), your other open PRs, and your
// assigned Linear issues (in-progress before todo). fzf opens instantly from
// cached data; PR review/CI/comment badges enrich in the background and fill in
// place via fzf's --listen reload. Each row opens its item on <enter>.
//
// Scope defaults to the current repo (its PRs + its Linear teams) and toggles to
// a global view with ctrl-g.

import { join } from "node:path";
import { run, openUrl } from "./shared/proc.ts";
import {
  RESET, DIM, C_GREEN, C_RED, C_AMBER, C_BLUE, C_GRAY,
  badge, dim, fg, visibleLen, spinnerFrame,
} from "./shared/ansi.ts";
import { cacheGet, cacheSet } from "./shared/cache.ts";
import { linearKey, linearIdentifier, fetchAssignedIssues, type AssignedIssue } from "./shared/linear.ts";
import {
  hasGh, searchAuthored, searchReviewRequested,
  fetchPrDetail, cachedPrDetail, type PrListItem, type PrDetail,
} from "./shared/github.ts";
import { launchFzf, signalFile, drainSignal } from "./shared/fzf.ts";

// --- open subcommand (invoked from fzf binds) -------------------------------
if (process.argv[2] === "open") {
  const url = process.argv[3];
  if (url) await openUrl(url);
  process.exit(0);
}

// --- config -----------------------------------------------------------------
const LISTS_TTL = 90 * 1000;
const CONCURRENCY = 8;
const TICK_MS = 120;

type Scope = "scoped" | "global";

type PrRow = PrListItem & {
  kind: "pr";
  authored: boolean;
  teamKey: string | null;
  state: "pending" | "done";
  detail: PrDetail | null;
};
type IssueRow = AssignedIssue & { kind: "issue" };
type Row = PrRow | IssueRow;

const key = linearKey();

// --- scope context ----------------------------------------------------------
async function currentRepoSlug(dir: string): Promise<string | null> {
  // `gh repo view` resolves renames to the canonical owner/repo the PR search
  // returns; the git remote can lag behind a rename and mismatch on scope.
  const gh = await run(["gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner"],
    { cwd: dir, timeoutMs: 4000 });
  if (gh.ok && gh.stdout.trim()) return gh.stdout.trim();
  const remote = await run(["git", "-C", dir, "remote", "get-url", "origin"]);
  const m = remote.stdout.trim().match(/github\.com[:/]([^/]+\/[^/]+?)(?:\.git)?$/);
  return m ? m[1] : null;
}

async function localTeamKeys(dir: string): Promise<Set<string>> {
  const teams = new Set<string>();
  const { stdout, ok } = await run(["git", "-C", dir, "for-each-ref", "--format=%(refname:short)", "refs/heads"]);
  if (ok) {
    for (const branch of stdout.split("\n")) {
      const id = linearIdentifier(branch);
      if (id) teams.add(id.split("-")[0]);
    }
  }
  return teams;
}

const cwd = process.cwd();
const currentRepo = await currentRepoSlug(cwd);
const currentTeams = await localTeamKeys(cwd);
// Always start scoped; ctrl-g is the only way into the global view. When the cwd
// isn't a resolvable repo, scoped simply shows nothing rather than dumping every
// PR across every repo.
let scope: Scope = "scoped";

// --- row assembly ------------------------------------------------------------
function toPrRow(item: PrListItem, authored: boolean): PrRow {
  const teamKey = linearIdentifier(item.title)?.split("-")[0] ?? null;
  // A PR whose Linear key surfaces in the current repo links that team into scope.
  if (teamKey && item.repo === currentRepo) currentTeams.add(teamKey);
  const detail = cachedPrDetail(item.repo, item.number);
  return {
    ...item, kind: "pr", authored, teamKey,
    state: detail ? "done" : "pending",
    detail: detail ?? null,
  };
}

function buildRows(authored: PrListItem[], review: PrListItem[], issues: AssignedIssue[]): Row[] {
  const authoredUrls = new Set(authored.map((p) => p.url));
  const prs = [
    ...authored.map((p) => toPrRow(p, true)),
    ...review.filter((p) => !authoredUrls.has(p.url)).map((p) => toPrRow(p, false)),
  ];
  const issueRows: IssueRow[] = issues.map((i) => ({ ...i, kind: "issue" }));
  return [...prs, ...issueRows];
}

// --- scope + sectioning ------------------------------------------------------
function inScope(r: Row): boolean {
  if (scope === "global") return true;
  return r.kind === "pr" ? r.repo === currentRepo : currentTeams.has(r.teamKey);
}

const isFlagged = (p: PrRow) =>
  p.state === "done" && !!p.detail &&
  (p.detail.ci === "FAIL" || p.detail.changes > 0 || p.detail.conflicting);

const sortByRepoNumber = (a: PrRow, b: PrRow) =>
  a.repo === b.repo ? b.number - a.number : a.repo.localeCompare(b.repo);

type Section = { label: string; rows: Row[] };

function sections(rows: Row[]): Section[] {
  const visible = rows.filter(inScope);
  const prs = visible.filter((r): r is PrRow => r.kind === "pr");
  const issues = visible.filter((r): r is IssueRow => r.kind === "issue");

  const review = prs.filter((p) => !p.authored);
  const authored = prs.filter((p) => p.authored);
  const flagged = authored.filter(isFlagged).sort(sortByRepoNumber);
  const healthy = authored.filter((p) => !isFlagged(p)).sort(sortByRepoNumber);

  const bySortOrder = (a: IssueRow, b: IssueRow) => a.sortOrder - b.sortOrder;
  const started = issues.filter((i) => i.stateType === "started").sort(bySortOrder);
  const todo = issues.filter((i) => i.stateType === "unstarted").sort(bySortOrder);

  return [
    { label: "Needs attention", rows: [...flagged, ...review.sort(sortByRepoNumber)] },
    { label: "Open PRs", rows: healthy },
    { label: "Assigned issues", rows: [...started, ...todo] },
  ].filter((s) => s.rows.length > 0);
}

// --- rendering ---------------------------------------------------------------
function prBadges(p: PrRow, frame: number): string {
  if (p.state === "pending") return spinnerFrame(frame);
  const parts: string[] = [];
  if (!p.authored) parts.push(badge(C_AMBER, "review"));
  const d = p.detail;
  if (d) {
    if (d.approvals > 0) parts.push(badge(C_GREEN, `✓ ${d.approvals}`));
    if (d.changes > 0) parts.push(badge(C_RED, `✗ ${d.changes}`));
    if (d.approvals === 0 && d.changes === 0 && p.authored) {
      parts.push(badge(p.draft ? C_GRAY : C_BLUE, "PR"));
    }
    if (d.ci === "PASS") parts.push(badge(C_GREEN, "✓ CI"));
    else if (d.ci === "FAIL") parts.push(badge(C_RED, "✗ CI"));
    else if (d.ci === "PENDING") parts.push(badge(C_AMBER, "● CI"));
    if (d.conflicting) parts.push(badge(C_RED, "⚠ conflict"));
    else if (d.mergeable) parts.push(badge(C_GREEN, "⇄ merge"));
    if (d.comments > 0) parts.push(dim(`💬 ${d.comments}`));
  }
  return parts.join(" ");
}

function issueBadge(i: IssueRow): string {
  return badge(i.stateColor, i.stateName);
}

function rowId(r: Row): string {
  return r.kind === "pr" ? `${r.repoName}#${r.number}` : r.identifier;
}

// A row is emitted as: key \t visibleLine \t primaryUrl \t ciUrl. fzf shows only
// field 2; the trailing URLs are what the open binds act on.
function encodeRow(visible: string, primaryUrl: string, ciUrl: string): string {
  return `row\t${visible}\t${primaryUrl}\t${ciUrl}`;
}

function render(rows: Row[], frame: number): string {
  const secs = sections(rows);
  if (secs.length === 0) {
    const msg = state.loaded
      ? (scope === "scoped" ? "Nothing here for this repo — ctrl-g for all." : "Nothing to show.")
      : "Loading…";
    return `hdr\t${dim(`  ${msg}`)}\t\t`;
  }

  const dataRows = secs.flatMap((s) => s.rows);
  const badgeOf = (r: Row, frame: number) => (r.kind === "pr" ? prBadges(r, frame) : issueBadge(r));
  const badgeW = Math.max(0, ...dataRows.map((r) => visibleLen(badgeOf(r, frame))));
  const idW = Math.max(0, ...dataRows.map((r) => rowId(r).length));

  const lines: string[] = [];
  for (const sec of secs) {
    const rule = "─".repeat(Math.max(0, 40 - sec.label.length));
    lines.push(`hdr\t${DIM}── ${sec.label} (${sec.rows.length}) ${rule}${RESET}\t\t`);
    for (const r of sec.rows) {
      const b = badgeOf(r, frame);
      const badgeCol = b + " ".repeat(badgeW - visibleLen(b));
      const idCol = rowId(r).padEnd(idW);
      let line: string;
      let ciUrl = "";
      if (r.kind === "pr") {
        line = `  ${badgeCol}  ${fg(C_BLUE, idCol)}  ${r.title}`;
        ciUrl = r.detail?.ciUrl ?? "";
      } else {
        const proj = r.project ? `  ${dim(r.project)}` : "";
        line = `  ${badgeCol}  ${idCol}  ${r.title}${proj}`;
      }
      lines.push(encodeRow(line, r.url, ciUrl));
    }
  }
  return lines.join("\n");
}

// --- data loading ------------------------------------------------------------
const state = { rows: [] as Row[], gen: 0, loaded: false };

type Lists = { authored: PrListItem[]; review: PrListItem[]; issues: AssignedIssue[] };

async function fetchLists(): Promise<Lists> {
  const [authored, review, issues] = await Promise.all([
    hasGh() ? searchAuthored() : Promise.resolve([]),
    hasGh() ? searchReviewRequested() : Promise.resolve([]),
    key ? fetchAssignedIssues(key) : Promise.resolve([]),
  ]);
  return { authored, review, issues };
}

function cachedLists(): Lists | null {
  const raw = cacheGet("dashboard-lists", LISTS_TTL);
  if (!raw) return null;
  try { return JSON.parse(raw) as Lists; } catch { return null; }
}

async function enrich(gen: number, onProgress: () => void) {
  const targets = state.rows.filter((r): r is PrRow => r.kind === "pr" && r.state === "pending");
  let idx = 0;
  const workers = Array.from({ length: Math.min(CONCURRENCY, targets.length) }, async () => {
    while (idx < targets.length) {
      const r = targets[idx++];
      const detail = await fetchPrDetail(r.repo, r.number);
      if (gen !== state.gen) return;
      r.detail = detail;
      r.state = "done";
      onProgress();
    }
  });
  await Promise.all(workers);
}

async function load(gen: number, lists: Lists, onProgress: () => void) {
  if (gen !== state.gen) return;
  state.rows = buildRows(lists.authored, lists.review, lists.issues);
  state.loaded = true;
  onProgress();
  await enrich(gen, onProgress);
}

// --- main --------------------------------------------------------------------
const launcher = join(import.meta.dir, "..", "launch.sh");
const scopeSignal = signalFile("dash_scope");
const refreshSignal = signalFile("dash_refresh");

function headerText(): string {
  const toggle = scope === "scoped" ? "show all" : "scope to repo";
  const scopeLabel = scope === "scoped" ? (currentRepo ?? "repo") : "all";
  return `enter: open   ^o: open CI   ^g: ${toggle}   ^r: refresh   esc: close    [${scopeLabel}]`;
}

const fzf = await launchFzf({
  tag: "dashboard",
  initial: render(state.rows, 0),
  args: [
    "--ansi", "--delimiter=\t", "--with-nth=2", "--no-sort", "--track", "--layout=reverse",
    "--prompt=dashboard > ",
    `--header=${headerText()}`,
    "--bind=ctrl-j:down,ctrl-k:up,ctrl-d:half-page-down,ctrl-u:half-page-up",
    `--bind=enter:execute-silent('${launcher}' dashboard open {3})`,
    `--bind=ctrl-o:execute-silent('${launcher}' dashboard open {4})`,
    `--bind=ctrl-g:execute-silent(echo 1 >> ${scopeSignal})`,
    `--bind=ctrl-r:execute-silent(echo 1 >> ${refreshSignal})`,
  ],
});

async function pushRender(frame: number) {
  await fzf.reload(render(state.rows, frame));
}

async function changeHeader() {
  if (!fzf.port) return;
  try {
    await fetch(`http://127.0.0.1:${fzf.port}`, { method: "POST", body: `change-header(${headerText()})` });
  } catch { /* fzf may have exited */ }
}

// Kick off the initial load: render from cache instantly if fresh, then always
// refetch so a stale cache is corrected within a couple of seconds.
let dirty = false;
const markDirty = () => { dirty = true; };

const cached = cachedLists();
if (cached) load(++state.gen, cached, markDirty);

(async () => {
  const fresh = await fetchLists();
  cacheSet("dashboard-lists", JSON.stringify(fresh));
  await load(++state.gen, fresh, markDirty);
})();

const anyPending = () => state.rows.some((r) => r.kind === "pr" && r.state === "pending");

let frame = 0;
let posting = false;
const ticker = fzf.port
  ? setInterval(async () => {
      if (posting) return;
      posting = true;
      try {
        // Scope toggle: flip, re-render, and update the header hint.
        if (drainSignal(scopeSignal).length > 0) {
          scope = scope === "scoped" ? "global" : "scoped";
          dirty = true;
          await changeHeader();
        }
        // Refresh: drop cached lists and refetch under a new generation so any
        // in-flight enrichment from the previous load is ignored.
        if (drainSignal(refreshSignal).length > 0) {
          const gen = ++state.gen;
          (async () => {
            const fresh = await fetchLists();
            cacheSet("dashboard-lists", JSON.stringify(fresh));
            await load(gen, fresh, markDirty);
          })();
        }
        if (anyPending()) { frame++; dirty = true; }
        if (dirty) { dirty = false; await pushRender(frame); }
      } finally { posting = false; }
    }, TICK_MS)
  : null;

await fzf.done;
if (ticker) clearInterval(ticker);
fzf.cleanup();
process.exit(0);
