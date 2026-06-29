---
name: aoe-linear
description: Spawn an Agent of Empires (aoe) opencode session for a Linear ticket. Use when the user says things like "aoe tkt-138", "start aoe with tkt-138", "aoe TKT-138", "spin up aoe for eng-42", or otherwise asks to start/launch an aoe session for a Linear issue identifier. The skill fetches the ticket from Linear, titles the session after the ticket's git branch name, and launches opencode in plan mode in a new worktree.
---

# aoe-linear

Launch a new Agent of Empires (aoe) session that opens opencode in plan mode
to plan work on a Linear ticket.

## When to Use This Skill

Use this skill when the user asks to start an aoe session for a Linear ticket.
Triggers include:

- `aoe tkt-138`
- `start aoe with tkt-138`
- `aoe TKT-138`
- `spin up aoe for eng-42`
- any message that pairs "aoe" with a Linear issue identifier (a team key
  like `tkt`/`eng` followed by `-` and a number)

This skill does NOT plan the ticket itself. It spawns a *separate* aoe-managed
opencode session that will do the planning. You are the launcher.

## What This Skill Does

Given a Linear identifier, you:

1. Look up the ticket in Linear.
2. Title an aoe session after the ticket's git branch name.
3. Launch opencode in plan mode in a fresh git worktree, pre-filled with a
   minimal planning prompt.

## Steps

Follow these in order. This is a rigid workflow — do not skip steps.

### 1. Parse and normalize the identifier

Extract the Linear identifier from the user's message. Normalize it to
Linear's canonical **uppercase** form:

- `tkt-138` -> `TKT-138`
- `eng-42` -> `ENG-42`

Call this `<ID>`.

### 2. Fetch the ticket from Linear

Use the Linear MCP `get_issue` tool with `<ID>`. From the result, read:

- `gitBranchName` — e.g. `jacob/tkt-138-multiple-tickets-option-to-delete-a-ticket`
- `title`
- `url`

If `get_issue` fails (e.g. the ticket does not exist or the identifier is
wrong), stop and tell the user — do not guess a branch name.

### 3. Derive the session title

The session **title** is the `gitBranchName` value, used **verbatim**. Do not
re-slugify it, do not add or change the `jacob/` prefix — Linear already
produces the desired format and a valid git branch name.

Call this `<TITLE>` (it equals `gitBranchName`).

### 3b. Derive the group

Sessions are organized under a `<repo>/in-progress` group, where `<repo>` is
the current repository's name (the git toplevel basename):

```sh
REPO="$(basename "$(git rev-parse --show-toplevel)")"
```

The group is `"$REPO/in-progress"`. Call this `<GROUP>`.

### 4. Launch the aoe session

Run two bash commands. Replace `<TITLE>`, `<GROUP>`, and `<ID>` with the real
values.

First, create the session (note: **no** `--launch`):

```sh
aoe add . \
  --title "<TITLE>" \
  --group "<GROUP>" \
  --worktree "<TITLE>" -b \
  --extra-args "--agent plan --prompt 'Come up with a plan for <ID>'"
```

If `aoe add` fails because the nested group path does not exist, create it and
retry the command above:

```sh
aoe group create in-progress --parent "<REPO>"
```

Then start its tmux process (this does **not** attach your terminal, so it
never emits a `not a terminal` error):

```sh
aoe session start "<TITLE>"
```

Notes on each flag:

- `aoe add .` — target the **current repository** as the project path.
- `--title "<TITLE>"` — the Linear git branch name.
- `--group "<GROUP>"` — organize the session under `<repo>/in-progress`
  (slash-delimited group path; `<repo>` is the git toplevel basename). aoe
  normally auto-creates the nested path; the `aoe group create` fallback above
  covers the case where it does not.
- `--worktree "<TITLE>" -b` — create a **new** git worktree and branch named
  `<TITLE>`, off the repository's default base branch. (The repo's aoe config
  places worktrees under `./.port/trees/{branch}` and runs `port <title>` on
  launch; these are complementary — do not add extra worktree handling.)
- `--extra-args "--agent plan --prompt 'Come up with a plan for <ID>'"` —
  appended after the `opencode` binary, so the spawned session runs
  `opencode --agent plan --prompt 'Come up with a plan for <ID>'`: plan mode
  with a minimal prompt. The spawned agent has the Linear MCP and can fetch
  full ticket details itself, so the prompt stays minimal.
- `aoe session start "<TITLE>"` — boots the session's tmux process without
  attaching. We deliberately avoid `--launch` (which tries to attach the
  current terminal and fails with `not a terminal` when run from a
  non-interactive agent). The started session shows up in any already-running
  aoe TUI / dashboard.

### 5. Report back

Tell the user, concisely:

- the session title (`<TITLE>`),
- that it started in plan mode and is now visible in the aoe dashboard,
- the ticket title and URL for reference.

Optionally mention that they can attach from a terminal with
`aoe session attach "<TITLE>"` if they want to jump straight in.

## Guardrails

- Never invent a `gitBranchName`. It must come from Linear.
- Use the title verbatim for both `--title` and `--worktree` so the session
  name and branch stay in sync.
- Keep the prompt minimal; do not stuff ticket description text into it.
- If multiple identifiers are mentioned, ask which one (or launch one session
  per ticket only if the user clearly asked for several).
