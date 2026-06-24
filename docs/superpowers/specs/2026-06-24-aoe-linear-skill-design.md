# aoe-linear Skill Design

Date: 2026-06-24

## Purpose

Let me say `aoe tkt-138` (or `start aoe with tkt-138`) to a running opencode
agent and have it spawn a new Agent of Empires (aoe) session that:

- is titled after the Linear ticket's git branch name (e.g.
  `jacob/tkt-138-multiple-tickets-option-to-delete-a-ticket`),
- runs in its own git worktree,
- launches opencode in **plan mode** with the prompt
  `Come up with a plan for TKT-138`.

## Feasibility

Verified locally:

- `aoe add` supports `--title`, `--worktree <branch> -b`, `--launch`, and
  `--extra-args` (appended after the agent binary).
- opencode's default (TUI) command accepts `--agent plan` and `--prompt`
  (flags parse cleanly), so `--extra-args "--agent plan --prompt '...'"`
  boots a session in plan mode with the prompt pre-filled.
- Linear MCP `get_issue` returns `gitBranchName` already in the desired
  `jacob/<id>-<slug>` form and as a valid git branch name.
- The repo's aoe config sets `worktree.path_template = "./.port/trees/{branch}"`
  and `on_launch = ["port $AOE_SESSION_TITLE"]`, so aoe worktrees ARE port
  worktrees — `--worktree` and the port hook are complementary, not
  conflicting.

## Mechanism

A skill is instructions loaded into the running agent's context, not a new
shell command. The phrase triggers the skill; the agent then executes the
steps below.

### Trigger

Natural-language phrases to a running opencode agent:

- `aoe tkt-138`
- `start aoe with tkt-138`
- `aoe TKT-138` / any Linear identifier (`tkt-138`, `eng-42`, ...)

The frontmatter `description` enumerates these so the agent loads the skill
on a low-probability match.

### Steps the skill instructs

1. Parse the identifier from the message; normalize to Linear's uppercase
   form (`tkt-138` -> `TKT-138`).
2. Fetch the ticket via Linear MCP `get_issue(<ID>)`. Read `gitBranchName`,
   `title`, `url`.
3. Session title = `gitBranchName` verbatim (carries the `jacob/` prefix,
   valid git branch name).
4. Launch with a single command:

   ```sh
   aoe add . \
     --title "<gitBranchName>" \
     --worktree "<gitBranchName>" -b \
     --launch \
     --extra-args "--agent plan --prompt 'Come up with a plan for <ID>'"
   ```

   - `--worktree <branch> -b` -> fresh worktree at `./.port/trees/{branch}`
     and new branch off the default base.
   - `--launch` -> starts immediately.
   - `--extra-args` -> spawned session runs `opencode --agent plan
     --prompt '...'` (plan mode, minimal prompt; spawned agent has Linear MCP
     to fetch details itself).
5. Report back: session title, worktree path, launch confirmation.

## Decisions (from brainstorming)

- Trigger: skill via phrase (not a standalone shell wrapper).
- Title slug: use Linear `gitBranchName` verbatim.
- Working dir: current repo (`aoe add .`); use aoe `--worktree` (port hook is
  complementary).
- Branch: always create new (`-b`) off the default base.
- Prompt: minimal (`Come up with a plan for <ID>`); spawned agent has Linear
  MCP.
- Launch flags: `--launch` + `--agent plan`. No `--model`, no group, terminal
  view (not `--structured-view`).

## File layout

- `shared/config/opencode/skills/aoe-linear/SKILL.md` — the skill. Picked up
  via the existing `~/.agents/skills` symlink in `shared/opencode.nix`.

## Out of scope (YAGNI)

- Detecting/reusing pre-existing branches.
- Per-ticket base-branch selection.
- Model pinning, groups, structured view.
- A separate terminal command/abbr.
