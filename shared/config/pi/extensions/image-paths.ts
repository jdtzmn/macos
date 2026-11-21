// Vendored unmodified from @mikefreno/pi-image-paths 0.1.1 (MIT, Michael Freno),
// source: https://git.freno.me/Mike/pi-image-paths. Replaces pi-image-view, whose
// path regex rejects the U+202F space in macOS screenshot filenames.
/**
 * image-paths — turn image file paths in chat input into attached images.
 *
 * 1. Live editor rewrite (TUI): the moment the input box ends with a path
 *    that resolves to an existing image file, the path is rewritten in
 *    place to "[Image #N]" — the same way pi collapses big pastes into
 *    "[paste #N +M lines]".
 *
 * 2. Send-time fallback: any image path still present in the prompt when
 *    it is submitted (un-rewritten, pasted whole, RPC mode, ...) is
 *    replaced with "[Image #N]" and the image is attached to the message.
 *
 * 3. Transcript render: once the message is sent, the attached images are
 *    drawn below it in the chat, honouring the `terminal.showImages` and
 *    `terminal.imageWidthCells` settings. Pi does not render image blocks on
 *    user messages itself, so the images ride in a custom session entry that
 *    stays out of the model context.
 *
 * Handles backslash-escaped spaces, quoted paths, ~ expansion, bare
 * filenames relative to cwd, and paths containing unescaped spaces
 * (disambiguated against the filesystem).
 */

import * as fs from "node:fs";
import * as os from "node:os";
import * as pathMod from "node:path";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Container, getCapabilities, Image, Spacer } from "@earendil-works/pi-tui";

export interface ImageContent {
  type: "image";
  data: string;
  mimeType: string;
}

const IMAGE_EXT = /\.(png|jpe?g|gif|webp|bmp)$/i;

const MIME_TYPES: Record<string, string> = {
  png: "image/png",
  jpg: "image/jpeg",
  jpeg: "image/jpeg",
  gif: "image/gif",
  webp: "image/webp",
  bmp: "image/bmp",
};

/** How many preceding whitespace-separated words may be joined into one path. */
const MAX_JOIN = 6;

/** Debounce for the live editor rewrite. */
const REWRITE_DEBOUNCE_MS = 120;

/** Custom entry that displays a sent message's images; never enters model context. */
const DISPLAY_ENTRY_TYPE = "image-paths:attached";

/** `terminal.imageWidthCells` default, used when the setting is unset. */
const DEFAULT_IMAGE_WIDTH_CELLS = 60;

interface AttachedImages {
  images: { data: string; mimeType: string }[];
}

/** Image blocks carried by a message, in order. */
function attachedImages(message: { content: unknown }): AttachedImages["images"] {
  if (!Array.isArray(message.content)) return [];
  const images: AttachedImages["images"] = [];
  for (const block of message.content) {
    if (!block || typeof block !== "object") continue;
    const { type, data, mimeType } = block as Partial<ImageContent>;
    if (type === "image" && data && mimeType) images.push({ data, mimeType });
  }
  return images;
}

interface Token {
  text: string;
  start: number;
  end: number;
}

/**
 * Split text into whitespace-separated tokens, treating a whitespace char
 * that is preceded by a backslash as part of the token (shell-style escaping).
 * All whitespace splits — including newlines — so multi-file drops and
 * multi-line prompts resolve per line.
 */
function tokenize(text: string): Token[] {
  const tokens: Token[] = [];
  let start = -1;
  for (let i = 0; i <= text.length; i++) {
    const ch = i < text.length ? text[i] : " ";
    const escapedSpace = /\s/.test(ch) && text[i - 1] === "\\";
    const boundary = i === text.length || (/\s/.test(ch) && !escapedSpace);
    if (!boundary && start === -1) start = i;
    if (boundary && start !== -1) {
      tokens.push({ text: text.slice(start, i), start, end: i });
      start = -1;
    }
  }
  return tokens;
}

/** Strip surrounding quotes and unescape shell backslash escapes. */
function cleanToken(raw: string): string {
  let s = raw.trim();
  if (s.length > 1 && (s.startsWith('"') || s.startsWith("'"))) s = s.slice(1);
  if (s.length > 1 && (s.endsWith('"') || s.endsWith("'"))) s = s.slice(0, -1);
  return s.replace(/\\([ '"()&;[\]])/g, "$1");
}

function expandTilde(p: string): string {
  if (p === "~") return os.homedir();
  if (p.startsWith("~/")) return pathMod.join(os.homedir(), p.slice(2));
  return p;
}

function looksPathish(p: string): boolean {
  return (
    p.startsWith("/") ||
    p.startsWith("~") ||
    p.startsWith("./") ||
    p.startsWith("../") ||
    /^[A-Za-z]:[\\/]/.test(p)
  );
}

function toAbs(p: string, cwd: string): string {
  // Some terminals drop files as file:// URIs.
  if (p.startsWith("file://")) {
    try {
      p = decodeURIComponent(p.slice(7));
    } catch {
      // Malformed escape: fall through with the raw remainder.
    }
    if (!p.startsWith("/")) p = "/" + p;
  }
  const expanded = expandTilde(p);
  return pathMod.isAbsolute(expanded)
    ? expanded
    : pathMod.resolve(cwd, expanded);
}

type Resolution =
  | { kind: "found"; start: number; end: number; file: string; ext: string }
  | { kind: "missing"; path: string }
  | { kind: "ignore" };

/**
 * Try to resolve the token at `index` (which ends with an image extension)
 * into an existing image file, optionally by joining up to MAX_JOIN
 * preceding tokens (for paths with unescaped spaces).
 */
function resolveImagePath(
  tokens: Token[],
  index: number,
  text: string,
  cwd: string,
): Resolution {
  // Skip URLs and tokens that don't actually end in an image extension
  // once trailing punctuation is stripped.
  const base = cleanToken(tokens[index].text).replace(/[.,;:!?)\]]+$/, "");
  if (!IMAGE_EXT.test(base) || /^(https?|ftp):/i.test(base))
    return { kind: "ignore" };

  let lastPathish: string | undefined;
  for (let k = 0; k <= MAX_JOIN && index - k >= 0; k++) {
    const first = tokens[index - k];
    const last = tokens[index];
    const candidate = cleanToken(text.slice(first.start, last.end)).replace(
      /[.,;:!?)\]]+$/,
      "",
    );
    if (candidate.includes("\n")) break; // never join across lines
    if (looksPathish(candidate)) lastPathish = candidate;

    const full = toAbs(candidate, cwd);
    try {
      if (fs.statSync(full).isFile()) {
        return {
          kind: "found",
          start: first.start,
          end: last.end,
          file: full,
          ext: IMAGE_EXT.exec(candidate)![1].toLowerCase(),
        };
      }
    } catch {
      // Not an existing file at this join width; try joining more words.
    }
  }

  if (lastPathish) return { kind: "missing", path: lastPathish };
  return { kind: "ignore" };
}

interface PathMatch {
  start: number;
  end: number;
  file: string;
  ext: string;
}

function findImagePaths(
  text: string,
  cwd: string,
): { found: PathMatch[]; missing: string[] } {
  const tokens = tokenize(text);
  const found: PathMatch[] = [];
  const missing: string[] = [];
  let lastEnd = -1;

  for (let i = 0; i < tokens.length; i++) {
    if (tokens[i].start < lastEnd) continue; // already consumed by an earlier join
    const base = cleanToken(tokens[i].text).replace(/[.,;:!?)\]]+$/, "");
    if (!IMAGE_EXT.test(base)) continue;

    const resolved = resolveImagePath(tokens, i, text, cwd);
    if (resolved.kind === "ignore") continue;
    if (resolved.kind === "missing") {
      missing.push(resolved.path);
      continue;
    }
    lastEnd = resolved.end;
    // Leave balanced surrounding quotes outside the match range.
    let start = resolved.start;
    let end = resolved.end;
    const raw = text.slice(start, end).trim();
    if (
      raw.length > 1 &&
      ((raw.startsWith('"') && raw.endsWith('"')) ||
        (raw.startsWith("'") && raw.endsWith("'")))
    ) {
      start += 1;
      end -= 1;
    }
    found.push({ start, end, file: resolved.file, ext: resolved.ext });
  }

  return { found, missing };
}

export interface ExtractedImages {
  /** Prompt text with each resolved path replaced by "[Image #N]". */
  text: string;
  /** Resolved files in order of appearance. */
  files: { file: string; ext: string }[];
  /** Path-looking candidates that did not exist on disk. */
  missing: string[];
}

/** Pure logic: find image paths in text and compute the transformed prompt. */
export function extractImages(
  text: string,
  cwd: string,
  startNumber = 1,
): ExtractedImages {
  const { found, missing } = findImagePaths(text, cwd);

  let out = "";
  let pos = 0;
  found.forEach((f, i) => {
    out += text.slice(pos, f.start) + `[Image #${startNumber + i}]`;
    pos = f.end;
  });
  out += text.slice(pos);

  return {
    text: out,
    files: found.map((f) => ({ file: f.file, ext: f.ext })),
    missing,
  };
}

/**
 * Pure logic: resolve trailing "[Image #N]" markers written by the live
 * editor rewrite into files, renumbering sequentially from 1. Unknown
 * markers (never registered by this session) are left as literal text.
 */
export function resolveImageMarkers(
  text: string,
  registry: Map<number, { file: string; ext: string }>,
): ExtractedImages {
  if (!text.includes("[Image #")) return { text, files: [], missing: [] };

  const files: { file: string; ext: string }[] = [];
  let out = "";
  let pos = 0;
  for (const m of text.matchAll(/\[Image #(\d+)\]/g)) {
    const entry = registry.get(Number(m[1]));
    if (!entry) continue;
    files.push(entry);
    out += text.slice(pos, m.index) + `[Image #${files.length}]`;
    pos = m.index + m[0].length;
  }
  out += text.slice(pos);
  return { text: out, files, missing: [] };
}

export default function (pi: ExtensionAPI) {
  // Session-scoped registry of live-rewritten markers: id -> file.
  const registry = new Map<number, { file: string; ext: string }>();
  let nextMarkerId = 0;
  let unsubscribeInput: (() => void) | undefined;
  let rewriteTimer: ReturnType<typeof setTimeout> | undefined;
  const displayTimers = new Set<ReturnType<typeof setTimeout>>();

  pi.registerEntryRenderer<AttachedImages>(
    DISPLAY_ENTRY_TYPE,
    (entry, _options, theme) => {
      const images = entry.data?.images ?? [];
      if (images.length === 0) return undefined;
      // Settings are live, so turning images off hides entries already in
      // the transcript the next time they are rebuilt.
      const settings = pi.getSettings();
      if (!(settings.terminal?.showImages ?? true)) return undefined;
      if (!getCapabilities().images) return undefined;
      const maxWidthCells =
        settings.terminal?.imageWidthCells ?? DEFAULT_IMAGE_WIDTH_CELLS;

      const container = new Container();
      for (const image of images) {
        container.addChild(new Spacer(1));
        container.addChild(
          new Image(
            image.data,
            image.mimeType,
            { fallbackColor: (text) => theme.fg("dim", text) },
            { maxWidthCells },
          ),
        );
      }
      return container;
    },
  );

  pi.on("session_start", (_event, ctx) => {
    nextMarkerId = 0;
    registry.clear();
    if (unsubscribeInput) {
      unsubscribeInput();
      unsubscribeInput = undefined;
    }
    // Live rewrite only makes sense with a real input box.
    if (ctx.mode !== "tui") return;

    unsubscribeInput = ctx.ui.onTerminalInput((data) => {
      // Enter submits the message — never schedule a rewrite for it.
      if (data !== "\r" && data !== "\n") scheduleRewrite(ctx);
      return undefined;
    });
  });

  pi.on("session_shutdown", () => {
    if (rewriteTimer) {
      clearTimeout(rewriteTimer);
      rewriteTimer = undefined;
    }
    for (const timer of displayTimers) clearTimeout(timer);
    displayTimers.clear();
    if (unsubscribeInput) {
      unsubscribeInput();
      unsubscribeInput = undefined;
    }
  });

  function scheduleRewrite(ctx: ExtensionContext) {
    if (rewriteTimer) return;
    rewriteTimer = setTimeout(() => {
      rewriteTimer = undefined;
      // Re-read the editor at fire time: pastes (drag & drop included)
      // land in the editor *after* this listener saw the raw sequence.
      const current = ctx.ui.getEditorText();
      if (!current || current.includes("[paste #")) return;

      // Rewrite EVERY resolvable path in one pass, so dropping several
      // files at once flips them all to markers immediately.
      const { found } = findImagePaths(current, ctx.cwd);
      if (found.length === 0) return;

      let out = "";
      let pos = 0;
      for (const f of found) {
        const id = ++nextMarkerId;
        registry.set(id, { file: f.file, ext: f.ext });
        out += current.slice(pos, f.start) + `[Image #${id}]`;
        pos = f.end;
      }
      out += current.slice(pos);
      ctx.ui.setEditorText(out);
    }, REWRITE_DEBOUNCE_MS);
  }

  // Pi renders image blocks on tool results but not on user messages, so the
  // attached images are re-drawn from a session entry appended right after the
  // message lands. Entries are excluded from the model context.
  pi.on("message_end", (event, ctx) => {
    if (ctx.mode !== "tui") return;
    if (event.message.role !== "user") return;
    const images = attachedImages(event.message);
    if (images.length === 0) return;
    if (!(pi.getSettings().terminal?.showImages ?? true)) return;

    // The session appends the user message after this handler returns, so
    // wait a macrotask to place the images directly below it.
    const timer = setTimeout(() => {
      displayTimers.delete(timer);
      pi.appendEntry<AttachedImages>(DISPLAY_ENTRY_TYPE, { images });
    }, 0);
    displayTimers.add(timer);
  });

  pi.on("input", async (event, ctx) => {
    // Never touch extension-injected messages.
    if (event.source === "extension") return { action: "continue" };
    if (!event.text.includes(".") && !event.text.includes("[Image #")) {
      return { action: "continue" };
    }

    // 1. Resolve markers written by the live editor rewrite.
    const markers = resolveImageMarkers(event.text, registry);

    // 2. Fall back to path detection for anything still un-rewritten.
    const extracted = extractImages(
      markers.text,
      ctx.cwd,
      markers.files.length + 1,
    );

    const allFiles = [...markers.files, ...extracted.files];
    if (allFiles.length === 0) {
      if (extracted.missing.length > 0 && ctx.hasUI) {
        ctx.ui.notify(
          `Image file not found: ${extracted.missing.join(", ")}`,
          "warning",
        );
      }
      return { action: "continue" };
    }

    const images: ImageContent[] = [];
    try {
      for (const f of allFiles) {
        const data = await fs.promises.readFile(f.file);
        images.push({
          type: "image",
          data: data.toString("base64"),
          mimeType: MIME_TYPES[f.ext] ?? "application/octet-stream",
        });
      }
    } catch (err) {
      // File vanished or became unreadable between stat and read: send the
      // original prompt untouched rather than a half-attached message.
      if (ctx.hasUI) {
        ctx.ui.notify(
          `Failed to read image, sending path as text: ${err}`,
          "warning",
        );
      }
      return { action: "continue" };
    }

    if (extracted.missing.length > 0 && ctx.hasUI) {
      ctx.ui.notify(
        `Image file not found: ${extracted.missing.join(", ")}`,
        "warning",
      );
    }

    return { action: "transform", text: extracted.text, images };
  });
}
