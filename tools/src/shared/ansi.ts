// ANSI colours and the bracketed [ label ] badge used across the tools.

export const RESET = "\x1b[0m";
export const YELLOW = "\x1b[33m";
export const DIM = "\x1b[90m";

// Badge palette (GitHub-ish). Linear badges use the issue state's own colour.
export const C_GREEN = "#3fb950";
export const C_RED = "#f85149";
export const C_AMBER = "#d29922";
export const C_BLUE = "#58a6ff";
export const C_GRAY = "#6e7681";

export const SPINNER = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

export const visibleLen = (s: string) => s.replace(/\x1b\[[0-9;]*m/g, "").length;

export const dim = (s: string) => `${DIM}${s}${RESET}`;
export const yellow = (s: string) => `${YELLOW}${s}${RESET}`;

function hexRgb(hex: string): [number, number, number] {
  const h = hex.replace("#", "");
  return [parseInt(h.slice(0, 2), 16), parseInt(h.slice(2, 4), 16), parseInt(h.slice(4, 6), 16)];
}

// A bracketed badge: [ label ], with the text (not a background) in the colour.
export function badge(colorHex: string, label: string): string {
  const [r, g, b] = hexRgb(colorHex);
  return `\x1b[38;2;${r};${g};${b}m[ ${label} ]${RESET}`;
}

// Colour the text only, no brackets.
export function fg(colorHex: string, label: string): string {
  const [r, g, b] = hexRgb(colorHex);
  return `\x1b[38;2;${r};${g};${b}m${label}${RESET}`;
}

function hslRgb(h: number, s: number, l: number): [number, number, number] {
  if (s === 0) { const v = Math.round(l * 255); return [v, v, v]; }
  const hue2rgb = (p: number, q: number, t: number) => {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  };
  const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
  const p = 2 * l - q;
  return [
    Math.round(hue2rgb(p, q, h + 1 / 3) * 255),
    Math.round(hue2rgb(p, q, h) * 255),
    Math.round(hue2rgb(p, q, h - 1 / 3) * 255),
  ];
}

// A stable, well-spread colour derived from an arbitrary key. Equal keys always
// produce the same colour, so callers can colour-group related rows. Hue,
// saturation and lightness each draw from a different slice of the hash so two
// keys that happen to share a hue still differ in tone.
export function colorFromKey(key: string): string {
  let hash = 2166136261;
  for (let i = 0; i < key.length; i++) {
    hash ^= key.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }
  const h = hash >>> 0;
  const hue = (h % 360) / 360;
  const sat = 0.52 + (Math.floor(h / 360) % 5) * 0.09; // 0.52..0.88
  const light = 0.55 + (Math.floor(h / 1800) % 4) * 0.055; // 0.55..0.715
  const [r, g, b] = hslRgb(hue, sat, light);
  return `#${[r, g, b].map((v) => v.toString(16).padStart(2, "0")).join("")}`;
}

export const spinnerFrame = (frame: number) => dim(SPINNER[frame % SPINNER.length]);
