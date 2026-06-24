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

### 4. Launch the aoe session

Run exactly one bash command. Replace `<TITLE>` and `<ID>` with the real
values:

```sh
aoe add . \
  --title "<TITLE>" \
  --worktree "<TITLE>" -b \
  --launch \
  --extra-args "--agent plan --prompt 'Come up with a plan for <ID>'"
```

Notes on each flag:

- `aoe add .` — target the **current repository** as the project path.
- `--title "<TITLE>"` — the Linear git branch name.
- `--worktree "<TITLE>" -b` — create a **new** git worktree and branch named
  `<TITLE>`, off the repository's default base branch. (The repo's aoe config
  places worktrees under `./.port/trees/{branch}` and runs `port <title>` on
  launch; these are complementary — do not add extra worktree handling.)
- `--launch` — start the session immediately.
- `--extra-args "--agent plan --prompt 'Come up with a plan for <ID>'"` —
  appended after the `opencode` binary, so the spawned session runs
  `opencode --agent plan --prompt 'Come up with a plan for <ID>'`: plan mode
  with a minimal prompt. The spawned agent has the Linear MCP and can fetch
  full ticket details itself, so the prompt stays minimal.

### 5. Report back

Tell the user, concisely:

- the session title (`<TITLE>`),
- that it launched in plan mode,
- the ticket title and URL for reference.

## Guardrails

- Never invent a `gitBranchName`. It must come from Linear.
- Use the title verbatim for both `--title` and `--worktree` so the session
  name and branch stay in sync.
- Keep the prompt minimal; do not stuff ticket description text into it.
- If multiple identifiers are mentioned, ask which one (or launch one session
  per ticket only if the user clearly asked for several).
