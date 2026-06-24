// Linear GraphQL access: single-issue lookup (switcher) and the viewer's
// assigned issues (dashboard).

import { readFileSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";
import { cacheGet, cacheSet } from "./cache.ts";
import { C_GRAY } from "./ansi.ts";

const API = "https://api.linear.app/graphql";
const ISSUE_TTL = 2 * 60 * 1000; // workflow state changes often enough to keep this short

export type LinearInfo = { title: string; stateName: string; stateColor: string; url: string };

export type AssignedIssue = {
  identifier: string;
  teamKey: string;
  title: string;
  url: string;
  stateType: "started" | "unstarted";
  stateName: string;
  stateColor: string;
  project: string | null;
  sortOrder: number;
};

export function linearKey(): string {
  if (process.env.LINEAR_API_KEY) return process.env.LINEAR_API_KEY;
  try {
    const secrets = readFileSync(join(homedir(), ".secrets"), "utf8");
    const m = secrets.match(/LINEAR_API_KEY\s*=\s*(['"]?)([^'"\n]+)\1/);
    if (m) return m[2];
  } catch { /* no secrets file */ }
  return "";
}

export function linearIdentifier(branch: string): string | null {
  const m = branch.match(/([A-Za-z]+)-([0-9]+)/);
  return m ? `${m[1].toUpperCase()}-${parseInt(m[2], 10)}` : null;
}

async function query<T>(key: string, body: object, timeoutMs = 5000): Promise<T | null> {
  try {
    const res = await fetch(API, {
      method: "POST",
      headers: { Authorization: key, "Content-Type": "application/json" },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(timeoutMs),
    });
    return (await res.json()) as T;
  } catch {
    return null;
  }
}

export async function fetchLinear(id: string, key: string): Promise<LinearInfo | null> {
  const [team, numStr] = id.split("-");
  const json = await query<any>(key, {
    query:
      "query($team:String!,$number:Float!){issues(filter:{team:{key:{eq:$team}},number:{eq:$number}},first:1){nodes{title url state{name color}}}}",
    variables: { team, number: parseInt(numStr, 10) },
  });
  const node = json?.data?.issues?.nodes?.[0];
  if (!node) return null;
  const info: LinearInfo = {
    title: node.title ?? "",
    stateName: node.state?.name ?? "",
    stateColor: node.state?.color ?? C_GRAY,
    url: node.url ?? "",
  };
  cacheSet(`linear-${id}`, JSON.stringify(info));
  return info;
}

// Cached wrapper: resolve an issue from disk first, only hitting the API on miss.
export function cachedLinear(id: string): LinearInfo | null | undefined {
  const cached = cacheGet(`linear-${id}`, ISSUE_TTL);
  if (cached === null) return undefined; // not cached -> caller should fetch
  try { return JSON.parse(cached) as LinearInfo; } catch { return undefined; }
}

export async function fetchAssignedIssues(key: string): Promise<AssignedIssue[]> {
  const json = await query<any>(key, {
    query:
      "{viewer{assignedIssues(first:100,filter:{state:{type:{in:[\"started\",\"unstarted\"]}}}){nodes{identifier title url branchName sortOrder state{name color type} team{key} project{name}}}}}",
  }, 6000);
  const nodes: any[] = json?.data?.viewer?.assignedIssues?.nodes ?? [];
  return nodes.map((n) => ({
    identifier: n.identifier ?? "",
    teamKey: n.team?.key ?? (n.identifier?.split("-")[0] ?? ""),
    title: n.title ?? "",
    url: n.url ?? "",
    stateType: n.state?.type === "started" ? "started" : "unstarted",
    stateName: n.state?.name ?? "",
    stateColor: n.state?.color ?? C_GRAY,
    project: n.project?.name ?? null,
    sortOrder: typeof n.sortOrder === "number" ? n.sortOrder : 0,
  }));
}
