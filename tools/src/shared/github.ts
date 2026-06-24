// GitHub access via the `gh` CLI: CI rollup interpretation, per-PR enrichment
// (by branch for the switcher, by repo+number for the dashboard), and the two
// PR searches the dashboard lists.

import { run } from "./proc.ts";
import { cacheGet, cacheSet, sanitize } from "./cache.ts";

export type CiState = "PASS" | "FAIL" | "PENDING" | null;

const CI_FAIL = ["FAILURE", "ERROR", "TIMED_OUT", "CANCELLED", "ACTION_REQUIRED", "STARTUP_FAILURE"];
const CI_PEND = ["PENDING", "IN_PROGRESS", "QUEUED", "EXPECTED", "WAITING", "REQUESTED", ""];
const ciStateOf = (c: any) => String(c.conclusion || c.state || c.status || "").toUpperCase();

export function rollupCI(rollup: any): CiState {
  if (!Array.isArray(rollup) || rollup.length === 0) return null;
  const states = rollup.map(ciStateOf);
  if (states.some((s) => CI_FAIL.includes(s))) return "FAIL";
  if (states.some((s) => CI_PEND.includes(s))) return "PENDING";
  return "PASS";
}

// Link to the most relevant check — a failing one first — falling back to the
// PR's Checks tab when the individual checks carry no URL of their own.
export function rollupUrl(rollup: any, prUrl: string): string | null {
  if (!Array.isArray(rollup) || rollup.length === 0) return null;
  const chosen = rollup.find((c) => CI_FAIL.includes(ciStateOf(c))) ?? rollup[0];
  return (chosen?.detailsUrl || chosen?.targetUrl || (prUrl ? `${prUrl}/checks` : "")) || null;
}

export const hasGh = () => !!Bun.which("gh");

// --- switcher: PR for the branch checked out in a working directory ----------

const PR_TTL = 180 * 1000; // review/CI state changes often

export type PrInfo = {
  draft: boolean;
  approvals: number;
  changes: number;
  ci: CiState;
  url: string;
  ciUrl: string | null;
};

function parsePrInfo(j: any): PrInfo | null {
  if (j.state !== "OPEN") return null;
  const reviews: any[] = j.latestReviews ?? [];
  const prUrl = j.url ?? "";
  return {
    draft: !!j.isDraft,
    approvals: reviews.filter((r) => r.state === "APPROVED").length,
    changes: reviews.filter((r) => r.state === "CHANGES_REQUESTED").length,
    ci: rollupCI(j.statusCheckRollup),
    url: prUrl,
    ciUrl: rollupUrl(j.statusCheckRollup, prUrl),
  };
}

export function cachedPrByBranch(dir: string, branch: string): PrInfo | null | undefined {
  const cached = cacheGet(`pr-${sanitize(`${dir}|${branch}`)}`, PR_TTL);
  if (cached === null) return undefined; // not cached
  if (cached === "") return null;        // cached "no open PR"
  try { return JSON.parse(cached) as PrInfo; } catch { return undefined; }
}

export async function fetchPrByBranch(dir: string, branch: string): Promise<PrInfo | null> {
  const { stdout, ok } = await run(
    ["gh", "pr", "view", branch, "--json", "state,isDraft,latestReviews,statusCheckRollup,url"],
    { cwd: dir, timeoutMs: 5000 },
  );
  let data: PrInfo | null = null;
  if (ok && stdout.trim()) {
    try { data = parsePrInfo(JSON.parse(stdout)); } catch { /* unparseable */ }
  }
  cacheSet(`pr-${sanitize(`${dir}|${branch}`)}`, data ? JSON.stringify(data) : "");
  return data;
}

// --- dashboard: PR lists + enrichment by repo+number -------------------------

export type PrListItem = {
  repo: string;      // owner/repo
  repoName: string;  // short repo name
  number: number;
  title: string;
  url: string;
  draft: boolean;
};

export type PrDetail = {
  approvals: number;
  changes: number;
  comments: number;
  ci: CiState;
  ciUrl: string | null;
  mergeable: boolean;   // ready to merge now: required checks pass, approvals met, no conflicts
  conflicting: boolean; // conflicts with the base branch
};

async function searchPrs(filterFlag: string): Promise<PrListItem[]> {
  const { stdout, ok } = await run(
    ["gh", "search", "prs", filterFlag, "@me", "--state", "open",
     "--json", "repository,number,title,url,isDraft", "--limit", "50"],
    { timeoutMs: 8000 },
  );
  if (!ok || !stdout.trim()) return [];
  try {
    const arr: any[] = JSON.parse(stdout);
    return arr.map((p) => ({
      repo: p.repository?.nameWithOwner ?? "",
      repoName: p.repository?.name ?? "",
      number: p.number,
      title: p.title ?? "",
      url: p.url ?? "",
      draft: !!p.isDraft,
    }));
  } catch {
    return [];
  }
}

export const searchAuthored = () => searchPrs("--author");
export const searchReviewRequested = () => searchPrs("--review-requested");

const DETAIL_TTL = 180 * 1000;

export function cachedPrDetail(repo: string, number: number): PrDetail | undefined {
  const cached = cacheGet(`prd-${sanitize(`${repo}#${number}`)}`, DETAIL_TTL);
  if (cached === null) return undefined;
  try { return JSON.parse(cached) as PrDetail; } catch { return undefined; }
}

// Linear and GitHub bots mirror activity into PR comments; exclude them so the
// badge reflects human discussion only. These bots post as regular users
// (no [bot] suffix), so match their login prefixes explicitly.
const BOT_LOGIN_PREFIXES = ["linear", "github-actions"];

function isHumanComment(comment: any): boolean {
  const login = String(comment?.author?.login ?? "").toLowerCase();
  if (login === "" || login.endsWith("[bot]")) return false;
  return !BOT_LOGIN_PREFIXES.some((prefix) => login.startsWith(prefix));
}

const DETAIL_FIELDS = "isDraft,latestReviews,statusCheckRollup,comments,url,mergeable,mergeStateStatus";

async function fetchPrDetailJson(repo: string, number: number): Promise<any | null> {
  const { stdout, ok } = await run(
    ["gh", "pr", "view", String(number), "--repo", repo, "--json", DETAIL_FIELDS],
    { timeoutMs: 6000 },
  );
  if (!ok || !stdout.trim()) return null;
  try { return JSON.parse(stdout); } catch { return null; }
}

function parsePrDetail(j: any): PrDetail {
  const reviews: any[] = j.latestReviews ?? [];
  const prUrl = j.url ?? "";
  const mergeState = String(j.mergeStateStatus ?? "").toUpperCase();
  return {
    approvals: reviews.filter((r) => r.state === "APPROVED").length,
    changes: reviews.filter((r) => r.state === "CHANGES_REQUESTED").length,
    comments: Array.isArray(j.comments) ? j.comments.filter(isHumanComment).length : 0,
    ci: rollupCI(j.statusCheckRollup),
    ciUrl: rollupUrl(j.statusCheckRollup, prUrl),
    mergeable: mergeState === "CLEAN",
    conflicting: String(j.mergeable ?? "").toUpperCase() === "CONFLICTING" || mergeState === "DIRTY",
  };
}

export async function fetchPrDetail(repo: string, number: number): Promise<PrDetail | null> {
  let j = await fetchPrDetailJson(repo, number);
  // GitHub computes mergeability lazily: the first request kicks it off and
  // returns UNKNOWN. Give it a moment and ask once more so the badge resolves.
  if (j && String(j.mergeable ?? "").toUpperCase() === "UNKNOWN") {
    await new Promise((resolve) => setTimeout(resolve, 1500));
    j = (await fetchPrDetailJson(repo, number)) ?? j;
  }
  const data = j ? parsePrDetail(j) : null;
  if (data) cacheSet(`prd-${sanitize(`${repo}#${number}`)}`, JSON.stringify(data));
  return data;
}
