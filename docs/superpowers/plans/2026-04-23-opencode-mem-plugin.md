# opencode-mem Plugin Integration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the `opencode-mem` persistent memory plugin to the local OpenCode config with auto-capture, memory injection, and web UI enabled.

**Architecture:** Add `"opencode-mem"` to the `plugin` array in `opencode.jsonc`, then create `opencode-mem.jsonc` alongside it with explicit settings. Both files are already live at `~/.config/opencode/` via the existing out-of-store symlink in `shared/opencode.nix` — no Nix rebuild required.

**Tech Stack:** JSONC config files only. No code, no build step.

---

### Task 1: Add plugin entry to opencode.jsonc

**Files:**
- Modify: `shared/config/opencode/opencode.jsonc:42-47`

- [ ] **Step 1: Add `"opencode-mem"` to the plugin array**

In `shared/config/opencode/opencode.jsonc`, change the `"plugin"` array from:

```jsonc
  "plugin": [
    "@0xsero/open-queue",
    "premind@git+https://github.com/jdtzmn/premind.git",
    "superpowers@git+https://github.com/obra/superpowers.git",
    "opencode-delegated-access@git+https://github.com/jdtzmn/opencode-delegated-access.git",
  ],
```

to:

```jsonc
  "plugin": [
    "@0xsero/open-queue",
    "premind@git+https://github.com/jdtzmn/premind.git",
    "superpowers@git+https://github.com/obra/superpowers.git",
    "opencode-delegated-access@git+https://github.com/jdtzmn/opencode-delegated-access.git",
    "opencode-mem",
  ],
```

- [ ] **Step 2: Verify the file looks correct**

Open `shared/config/opencode/opencode.jsonc` and confirm the plugin array has 5 entries and no syntax errors (trailing comma after last entry is fine — JSONC allows it).

- [ ] **Step 3: Commit**

```bash
git add shared/config/opencode/opencode.jsonc
git commit -m "Add opencode-mem to plugin list"
```

---

### Task 2: Create companion config opencode-mem.jsonc

**Files:**
- Create: `shared/config/opencode/opencode-mem.jsonc`

- [ ] **Step 1: Create the file**

Create `shared/config/opencode/opencode-mem.jsonc` with this exact content:

```jsonc
// opencode-mem configuration
// See https://github.com/tickernelz/opencode-mem for full docs.
{
  "opencodeProvider": "anthropic",
  "opencodeModel": "claude-sonnet-4-5-20250929",

  "autoCaptureEnabled": true,
  "autoCaptureLanguage": "auto",

  "webServerEnabled": true,
  "webServerPort": 4747,

  "chatMessage": {
    "enabled": true,
    "maxMemories": 3,
    "excludeCurrentSession": true,
    "injectOn": "first",
  },
}
```

- [ ] **Step 2: Verify the file is reachable via the symlink**

```bash
ls -la ~/.config/opencode/opencode-mem.jsonc
```

Expected: a symlink entry pointing into the repo (or the file itself if the symlink resolves transparently). If the symlink is a directory symlink (which it is — `~/.config/opencode` → `<repo>/shared/config/opencode`), the file should be visible.

- [ ] **Step 3: Commit**

```bash
git add shared/config/opencode/opencode-mem.jsonc
git commit -m "Add opencode-mem companion config"
```

---

### Task 3: Commit the spec and plan docs

**Files:**
- Add: `docs/superpowers/specs/2026-04-23-opencode-mem-plugin-design.md`
- Add: `docs/superpowers/plans/2026-04-23-opencode-mem-plugin.md`

- [ ] **Step 1: Stage and commit the docs**

```bash
git add docs/superpowers/specs/2026-04-23-opencode-mem-plugin-design.md
git add docs/superpowers/plans/2026-04-23-opencode-mem-plugin.md
git commit -m "Add opencode-mem design spec and implementation plan"
```
