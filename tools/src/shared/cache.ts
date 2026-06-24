// A tiny mtime-TTL file cache. All tmux tools share one root so, e.g., a Linear
// issue fetched by the switcher is instantly reused by the dashboard.

import { readFileSync, writeFileSync, statSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

const ROOT = `${process.env.XDG_CACHE_HOME ?? join(homedir(), ".cache")}/tmux_tools`;

export const sanitize = (s: string) => s.replace(/[^A-Za-z0-9._-]/g, "_").slice(0, 180);

export function cacheGet(name: string, ttlMs: number): string | null {
  const file = join(ROOT, name);
  try {
    if (Date.now() - statSync(file).mtimeMs < ttlMs) return readFileSync(file, "utf8");
  } catch { /* miss */ }
  return null;
}

export function cacheSet(name: string, value: string) {
  try {
    mkdirSync(ROOT, { recursive: true });
    writeFileSync(join(ROOT, name), value);
  } catch { /* best effort */ }
}
