# Hybrid tmux Session Plan

## Goal

- Auto-attach to tmux on shell start.
- Tie sessions to repo + branch/worktree when relevant.
- Avoid surprising session jumps on every `cd`.

## Session Identity

- Use `main` when outside any git repo.
- Use `repo:branch` when inside a git repo.
- If `PORT_WORKTREE` is set, use `PORT_WORKTREE` as the branch/worktree token (preferred over git branch).
- Sanitize session names to tmux-safe chars (`[A-Za-z0-9._:-]`), replacing `/` in branch names with `-`.

## Startup Behavior (Auto)

- Trigger only for interactive Fish shells.
- Skip auto-attach when:
  - already in tmux (`$TMUX` is set),
  - running non-interactive commands,
  - explicitly disabled via env flag (for example `NO_AUTO_TMUX=1`).
- On startup:
  1. Compute target session from current `$PWD`.
  2. Run `tmux new-session -A -s <target>` (attach or create).
- Result: opening WezTerm in a repo goes to `repo:branch`; opening elsewhere goes to `main`.

## Directory Change Behavior (Manual, Not Automatic)

- `cd` alone does not switch sessions.
- Provide explicit helper command (for example `ts`) to switch/create a session for current directory context:
  - Compute target from current `$PWD`.
  - If inside tmux: `tmux switch-client -t <target>` (create detached first if needed, then switch).
  - If outside tmux: `tmux new-session -A -s <target>`.
- Optional second helper (for example `tw`) to show/select known sessions.

## Port/Worktree Rules

- If `PORT_WORKTREE` exists, use it as the branch/worktree token.
- This maps each Port worktree to a distinct tmux session, even with similar paths.
- `port enter <branch>` plus `ts` should land in that worktree session.

## Creation and Lifetime

- Sessions are long-lived by default (manual cleanup).
- Do not auto-kill sessions when leaving a directory/worktree.
- Optional future cleanup helper can prune stale sessions.

## Collision Handling

- If two repos share the same basename, optionally append a short hash of repo root (for example `repo-<hash>:branch`).
- Truncate long branch tokens (for example 40 chars) for readability.

## UX Commands

- `ts` -> switch/create session for current context.
- `ts main` -> force switch to `main`.
- `tsl` -> list sessions with repo/branch hint.
- `tsk` -> kill current session (with confirmation).

## Observability

- Print one short status line on switch/create:
  - `tmux -> myrepo:feature-x (created)`
  - `tmux -> myrepo:feature-x (attached)`
  - `tmux -> myrepo:feature-x (switched)`

## Safety

- Do not auto-switch on `cd` by default.
- Keep behavior deterministic and explicit.
- Preserve current tmux server and existing status config.

## Implementation Targets

- `shared/config/config.fish` for startup logic and helper commands.
- `shared/fish.nix` only if new helper aliases/abbrs are desired there.
