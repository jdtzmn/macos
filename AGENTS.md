# AGENTS.md

Agent guidance for this repository.

## Scope
- Applies to the entire repo rooted at `/Users/jacob/Documents/GitHub/macos`.
- Primary stack: Nix flakes (`nix-darwin` + `home-manager`) plus dotfiles/configs.
- Most runtime changes are declarative Nix updates, then applied via `make` targets.

## Repository Map
- `flake.nix`: flake inputs/outputs and host definitions.
- `Makefile`: canonical entrypoints for applying host configs.
- `hosts/macbook/default.nix`: macOS system config via nix-darwin.
- `hosts/macbook/home.nix`: macOS Home Manager user config.
- `hosts/linux/home.nix`: Linux Home Manager config.
- `shared/*.nix`: shared Home Manager modules (fish, git, nvim, etc).
- `shared/config/*`: raw config files (fish, wezterm, opencode, nvim).

## Rule Files (Cursor/Copilot)
- No Cursor rule files found:
  - `.cursor/rules/**`
  - `.cursorrules`
- No Copilot instruction file found:
  - `.github/copilot-instructions.md`
- If these files are added later, treat them as higher-priority local policy and update this file.

## Environment and Secrets
- Never read or print values from `.env` files.
- You may verify existence/shape of `.env` files without exposing secrets.
- `README.md` expects creating `.env` from `.env.example` before running full setup.
- Some commands rely on environment passthrough (`sudo -E`, `--impure`).

## Build and Apply Commands
Use repo root unless noted.

```bash
# Show available targets
make help

# Apply macOS config (primary path)
make macbook

# Apply macOS config from separate admin account
make macbook-admin

# Apply Linux Home Manager config
make linux
```

Direct equivalents:

```bash
# macOS
REPO_DIR=$(pwd) sudo -E nix run nix-darwin -- switch --flake .#macbook --impure

# Linux
REPO_DIR=$(pwd) nix run home-manager -- switch --flake .#linux --impure
```

## Validation, Lint, and Test Commands
This repo does not have a conventional unit test suite. Use flake and target evaluation checks.

```bash
# Repo-level flake validation
nix flake check --impure

# "Single test" equivalent: evaluate one target only
nix eval .#homeConfigurations.linux.activationPackage.drvPath --impure
nix eval .#darwinConfigurations.macbook.system.drvPath --impure
nix eval .#darwinConfigurations.macbook-admin.system.drvPath --impure
```

Notes:
- Prefer target-specific evals when you only changed one host/module.
- `make macbook` / `make linux` are integration/apply steps, not lightweight tests.
- No flake formatter is configured (`nix fmt` is not available here).

## Language-Specific Formatting and Linting

### Nix
- No mandatory formatter configured in flake outputs.
- Keep edits minimal and preserve existing file-local style.
- Use semicolon-terminated assignments and explicit attr sets.

### Lua (Neovim config under `shared/nvim`)
- Formatting config exists: `shared/nvim/.stylua.toml`.
- Preferred formatter command:

```bash
stylua shared/nvim
```

- Stylua rules in this repo include:
  - 2-space indentation
  - max line width 120
  - Unix line endings

### JS (OpenCode plugin under `shared/config/opencode/plugins`)
- No repo-level eslint/vitest config is committed.
- Follow existing style in `notification.js` (const-first, guard clauses, async/await).
- If test tooling is added, also add exact single-test commands in this file.

## Code Style Guidelines

### General
- Make narrowly scoped changes; avoid opportunistic refactors.
- Preserve module boundaries (`hosts/*` for host-specific, `shared/*` for shared logic).
- Keep comments sparse and only for non-obvious intent.

### Imports and Module Structure
- Nix: keep argument sets explicit at top (`{ pkgs, repoDir ? null, ... }:`).
- Nix: place `imports` near the top of the module.
- Lua: keep `require` calls near top; localize frequently used module functions.
- Lua/Nix: prefer existing local naming patterns over introducing new conventions.

### Formatting
- Match surrounding indentation and brace/list layout in each file.
- Do not reformat entire files unless explicitly asked.
- Keep diff noise low (especially in declarative config files).

### Types and Data Modeling
- Nix: use explicit attr names and defaults for optional arguments (`? null`, `? false`).
- Lua/JS: validate nullable fields before use; treat external event payloads as untrusted.
- Prefer simple data structures and predictable shapes over clever abstractions.

### Naming Conventions
- Nix modules/files: lowercase with hyphen/word separation as already present.
- Env vars: `UPPER_SNAKE_CASE` (example: `GIT_SIGNING_KEY`).
- Lua locals/functions: `snake_case` style as used in repo.
- Keep command abbreviations short but clear (`dc`, `tf`, `lg`, etc).

### Error Handling
- Shell/Fish: guard external commands/files with existence checks before use.
- Lua/JS async calls: prefer try/catch around external API calls.
- Fail safely with early returns when required context is missing.
- Do not swallow errors silently unless intentional and low risk; when ignoring, do it explicitly.

## Agent Workflow Expectations
- Work in phases for larger changes.
- Validate the smallest affected target first, then broader checks if needed.
- Do not run destructive git commands (`reset --hard`, checkout rollback) unless requested.
- Do not amend commits unless explicitly requested.
- Commit message style is imperative and concise (no Conventional Commit prefixes required).

## Change Verification Checklist
- Confirm changed files match task scope.
- Run at least one relevant validation command from above.
- If host-specific change, run the corresponding single-target eval.
- If Lua changed, run `stylua shared/nvim`.
- Note any commands you could not run and why.

## When Unsure
- Prefer the simplest change that matches existing patterns.
- Ask for clarification only when ambiguity would materially change behavior.
- If adding new tooling (formatter/linter/test runner), update this file with exact commands,
  including a single-test command.
