// A thin controller around fzf's --listen HTTP API so a Bun orchestrator can
// stream re-renders into a running fzf while it stays open (spinners filling in,
// rows re-sorting) with --track keeping the cursor put.

import { readFileSync, writeFileSync, unlinkSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { run } from "./proc.ts";

export type FzfLive = {
  port: string;
  proc: Bun.Subprocess;
  reload: (text: string) => Promise<void>;
  done: Promise<string>;
  cleanup: () => void;
};

// Launch fzf with the given args plus the machinery to accept live reloads. The
// caller's args should include --ansi/--delimiter/--with-nth and any binds; this
// adds the port handshake and --listen.
export async function launchFzf(opts: { tag: string; args: string[]; initial: string }): Promise<FzfLive> {
  const portFile = join(tmpdir(), `${opts.tag}_port_${process.pid}`);
  const renderFile = join(tmpdir(), `${opts.tag}_render_${process.pid}`);
  try { unlinkSync(portFile); } catch {}

  const args = [
    ...opts.args,
    `--bind=start:execute-silent(echo $FZF_PORT > ${portFile})`,
    "--listen",
  ];
  const proc = Bun.spawn(["fzf", ...args], { stdin: "pipe", stdout: "pipe", stderr: "inherit" });
  proc.stdin!.write(opts.initial);
  proc.stdin!.end();

  let port = "";
  for (let i = 0; i < 100 && !port; i++) {
    try { port = readFileSync(portFile, "utf8").trim(); } catch {}
    if (!port) await Bun.sleep(30);
  }

  const reload = async (text: string) => {
    if (!port) return;
    writeFileSync(renderFile, text);
    try {
      await fetch(`http://127.0.0.1:${port}`, { method: "POST", body: `reload(cat '${renderFile}')` });
    } catch { /* fzf may have exited */ }
  };

  const done = new Response(proc.stdout).text();

  const cleanup = () => {
    try { unlinkSync(portFile); } catch {}
    try { unlinkSync(renderFile); } catch {}
  };

  return { port, proc, reload, done, cleanup };
}

// A file used as a one-way signal channel from an fzf bind back to the loop
// (fzf can only run shell, so key actions append to a file the loop drains).
export function signalFile(tag: string): string {
  const file = join(tmpdir(), `${tag}_${process.pid}`);
  try { unlinkSync(file); } catch {}
  return file;
}

export function drainSignal(file: string): string[] {
  let content: string;
  try { content = readFileSync(file, "utf8"); } catch { return []; }
  try { unlinkSync(file); } catch {}
  return content.split("\n").map((s) => s.trim()).filter(Boolean);
}

export async function displayMessage(msg: string) {
  await run(["tmux", "display-message", msg]);
}
