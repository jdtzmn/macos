# opencode-mem Plugin Integration — Design Spec

**Date:** 2026-04-23

## Goal

Add the `opencode-mem` persistent memory plugin to the local OpenCode configuration so that the coding agent retains context across sessions using a local vector database.

## Context

The OpenCode config lives at `shared/config/opencode/` and is exposed to `~/.config/opencode/` via a single out-of-store symlink managed by `shared/opencode.nix`. Any file added to `shared/config/opencode/` is immediately live — no Nix rebuild required.

Existing plugins (`premind`, `superpowers`, etc.) are declared in the `"plugin"` array in `opencode.jsonc`. Plugin-specific companion configs (e.g., `premind.jsonc`) live alongside `opencode.jsonc` in the same directory.

## Changes

### 1. `shared/config/opencode/opencode.jsonc`

Add `"opencode-mem"` to the `"plugin"` array. No other changes to this file.

### 2. `shared/config/opencode/opencode-mem.jsonc` (new file)

Companion config read by the plugin at startup. Keeps explicit, version-controlled settings rather than relying on defaults.

Key settings:
- **AI provider:** `anthropic` / `claude-sonnet-4-5-20250929` — uses existing Anthropic OAuth, no separate API key needed
- **Auto-capture:** enabled, language auto-detected
- **Web UI:** enabled on port 4747 (visual memory browsing at `http://127.0.0.1:4747`)
- **Chat message injection:** enabled, inject up to 3 relevant memories on the first message of each session, excluding memories from the current session

All other settings (storage path, embedding model, deduplication, compaction) left at plugin defaults.

## Architecture

- No Nix changes required — the symlink in `shared/opencode.nix` covers both files automatically.
- Plugin is downloaded by OpenCode on next startup from npm (`opencode-mem`).
- Memory data stored outside the repo at `~/.opencode-mem/data` (plugin default).

## Out of Scope

- Custom storage path configuration
- User name/email overrides
- Changing the embedding model
- Compaction tuning
