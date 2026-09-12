---
name: pi-lazy
description: Use when configuring, troubleshooting, or invoking deferred Pi packages in this repository. Covers package discovery, pi-lazy triggers, loading a package before its tools are available, and safe updates to shared/config/pi/lazy.json and settings.json.
---

# Pi Lazy Packages

## When to Use

Use this skill when a request mentions pi-lazy, a deferred Pi package, `/lazy`, missing Pi tools, lazy package startup, or the packages configured in `shared/config/pi/`.

## Discover and Load Packages

Deferred extension factories are intentionally absent at Pi startup. Their skills and prompts still load normally, but their extension tools do not appear until the package is loaded.

1. Inspect availability with `/lazy list` or `/lazy profile`.
2. To load a known package, run `/lazy load <name>`.
3. The agent can call `lazy_load({ name: "<name>" })` when that tool is available.
4. If a stub tool loaded the package, call the real tool on the following turn.

Configured package names:

- `context-mode` — context-preserving data processing
- `lens` — code intelligence and diagnostics
- `web` — web search, fetching, and video analysis
- `mcp` — MCP integrations
- `plannotator` — plan review workflow
- `btw` — side conversations
- `intercom` — local Pi-session communication
- `cmux` — cmux terminal integration
- `hermes-memory`, `subagents`, `ask-user`, `todo`, `ultra-compact` — loaded after startup

## Trigger Behavior

- `context-mode`, `ctx_execute`, diagnostics/LSP terms, web-search terms, MCP/Playwright terms, and the declared package tool or slash-command stubs can trigger loading automatically.
- Keyword auto-loading is enabled. Disable it for a session or persistently with `/lazy auto off`.
- Loaded packages remain active until Pi restarts; pi-lazy does not unload them mid-session.

## Configuration

- `shared/config/pi/lazy.json` controls load modes and triggers.
- `shared/config/pi/settings.json` contains package entries. An entry with `"extensions": []` prevents Pi from running that package's extension factory at startup; pi-lazy loads it later.
- Keep boot-critical packages eager. Preserve custom package filters, especially the `pi-background-tasks` Anthropic-attribution exclusion.
- `premind` is git-sourced and should remain eager unless pi-lazy is given a local package path.
- After configuration changes, restart Pi. Validate JSON and compare a clean-launch startup-header measurement before and after changes.
