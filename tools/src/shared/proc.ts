// Subprocess + URL helpers shared by every tmux tool.

export async function run(
  cmd: string[],
  opts: { cwd?: string; timeoutMs?: number } = {},
): Promise<{ stdout: string; ok: boolean }> {
  try {
    const proc = Bun.spawn(cmd, { cwd: opts.cwd, stdout: "pipe", stderr: "ignore" });
    let timedOut = false;
    const timer = opts.timeoutMs
      ? setTimeout(() => { timedOut = true; proc.kill(); }, opts.timeoutMs)
      : null;
    const stdout = await new Response(proc.stdout).text();
    const code = await proc.exited;
    if (timer) clearTimeout(timer);
    return { stdout, ok: code === 0 && !timedOut };
  } catch {
    return { stdout: "", ok: false };
  }
}

export function openUrl(url: string) {
  return run([process.platform === "darwin" ? "open" : "xdg-open", url]);
}
