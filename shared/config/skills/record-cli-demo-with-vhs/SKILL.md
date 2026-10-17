---
name: record-cli-demo-with-vhs
description: Record a real CLI or TUI workflow as a reproducible VHS GIF/MP4; use when asked to make a terminal demo, capture a spinner, or preview CLI behavior.
---

# Record a CLI demo with VHS

## When to Use
Use for reproducible terminal demos of CLI features or TUIs, including progress states that finish too quickly to capture reliably.

## Procedure
1. Prepare an isolated scratch directory and fixture. Demonstrate the actual CLI, not a simulated animation. For Git workflows, use a disposable repository and local remote. If needed, add a narrowly scoped fixture-only delay and disclose it.
2. Write a VHS tape with relative `Output` and `Screenshot` paths. Hide setup commands, type the demo command, use `Wait+Screen` on observable progress text, capture an in-progress screenshot, then wait for the final result. Run VHS from the artifact directory.
3. Run `vhs validate demo.tape`, then `vhs demo.tape`. Bound a potentially long render with the agent's background-task facility when available.
4. Inspect the in-progress screenshot and a final frame. Use `ffprobe` to check the MP4's duration and dimensions; retain the tape, GIF, and MP4 as local artifacts.
5. If a side-by-side preview was requested and `terminal-browser` is available, make a local HTML viewer for the MP4 (muted autoplay, loop, controls); open it in a right split, verify video readiness/duration/error, then call `terminal-browser action done`. Otherwise, give the user the artifact paths for their preferred viewer.
6. Report artifact paths and any fixture-only delays or stubs. Keep recordings local unless publication was requested; leave unrelated worktrees and services untouched.

## Pitfalls
- VHS 0.10 may reject unquoted absolute `Output` and `Screenshot` paths. Prefer relative paths and render from the artifact directory.
- A fixed `Sleep` after Enter can capture startup instead of progress. Prefer `Wait+Screen` before the screenshot.
- Some spinners disable animation outside a usable TTY or in CI; record in VHS's terminal with CI disabled in the isolated fixture when appropriate.
- Shell startup can expose paths or secrets. Use an isolated HOME, hide setup commands, and never read `.env` files.
- `terminal-browser action done` is a top-level subcommand, not `action -- done`.

## Verification
1. VHS produced the GIF and MP4; `ffprobe` reports a nonzero duration and expected dimensions.
2. The in-progress frame shows authentic CLI feedback and the final frame shows the outcome.
3. If previewing, the video loads and plays without error; the working repository has no unintended changes.
