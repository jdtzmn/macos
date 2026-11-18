---
name: delegate
description: Turn this session into a dispatcher that gives each pasted Linear issue a tab in the Rex session for its workstream, with a Port worktree and a planning Pi agent, and sends each PR URL to a Pi agent in the Reviews session that summarizes it and flags blockers.
disable-model-invocation: true
---

# Delegate

This session is now a **dispatcher**. Whenever the user sends Linear issue IDs or PR URLs, hand each one to a fresh Pi agent (a **delegate**) in Rex. The dispatcher launches delegates; the delegates do the work.

- A Rex **session** is a workstream (`Repo`, `Tools`, `Reviews`) and a **tab** is one task in it. The dispatcher never creates a session per task.
- An **issue** gets a tab in the session for its workstream, a Port worktree on the issue's branch, and a delegate that researches and plans in it.
- A **PR URL** gets a tab in the shared `Reviews` session and a delegate that summarizes the PR and flags blockers.

## Start

1. Run `test -n "$REX_SESSION"`. If it fails, tell the user you are not inside Rex and stop.
2. The **review repo** is `git rev-parse --show-toplevel` from this session's directory, or `$HOME` if that fails. It is only the working directory for review tabs. Issues take their repo from **Routing**.
3. If the invocation carried issue IDs or PR URLs (`/skill:delegate PDX-1 https://github.com/o/r/pull/9`), dispatch them now. Otherwise reply in one line that dispatch mode is on and ask what to delegate.

## Dispatch mode

Dispatch mode lasts for the rest of this session, through compaction, until the user says to stop.

- A **dispatch message** contains only issue references (`PDX-4`, `pdx-4`, or a Linear issue URL) and PR URLs (`https://github.com/<owner>/<repo>/pull/<n>`), optionally with a mode word from **Issue modes**. Dispatch every item in it without asking. A PR URL is a review request only when the message is a dispatch message or the user asks to review it.
- Answer any other message as ordinary conversation, including ones that mention issues but ask something else ("is PDX-4 related to PDX-1?"). Dispatch from such a message only when the user asks for it.
- End every dispatch report with the `Routing:` line and then the line `Dispatch mode on.` so both survive summarization.

## Routing

The **routing table** lives in this conversation and starts empty. It holds two kinds of entries: `<Linear team key> → <repo path>` and `<repo directory name> → <session label>`. Every answer the user gives adds an entry, and later dispatches check the table first.

For each issue, resolve two things before launching:

1. **Repo.** Use the table entry for the issue's team key. Otherwise, if the issue has a GitHub attachment, use the local checkout whose `origin` matches that repository. Otherwise ask: `Which repo is <ID> in?`, offering the checkouts that sit next to this session's repo. Never guess from this session's own directory.
2. **Session**, in this order:
   - The user named one in the message (`PDX-1985 in Tools`). Add `<repo name> → <session>` to the table.
   - A table entry for the repo directory name.
   - An existing session whose label equals the repo directory name, ignoring case (`repo` finds `Repo`).
   - Otherwise ask: `Which session should <ID> go in? Existing: <labels>, or a new one named <repo name>?` Add the answer to the table. Never create a session without the user choosing one.

Ask once per question, covering every issue in the message that needs it.

## Issue modes

Each issue gets **plan** unless the user's message pairs that issue with a word like *implement*, *build*, *fix*, or *ship*. A mode word applies only to the issues in the same message.

| Mode | Delegate instruction (`<ID>` filled in) |
| --- | --- |
| plan | `Research Linear issue <ID> and propose an implementation plan. Plan only: leave files, commits, GitHub, and Linear untouched. Present the plan and wait for me.` |
| implement | `Research Linear issue <ID>, propose a plan, then implement it in phased commits. Push, open a PR, or update Linear only when I ask.` |

Send the instruction verbatim. The delegate reads the issue from Linear itself, so the instruction stays this short.

## Dispatch an issue

Run these steps for each issue, one at a time. One issue failing does not stop the others.

1. **Resolve.** Normalize the ID to uppercase (`pdx-4` → `PDX-4`). Fetch it with the Linear MCP `get_issue` tool and read `gitBranchName`, `title`, `url`, and the team. If the fetch fails, record the failure and move to the next issue. The branch always comes from Linear, verbatim.
2. **Route.** Resolve the repo and the session as described in **Routing**.
3. **Deduplicate.** Run `rex ls --json`, then `rex window ls -s <session> --json` for every session. If any window `label` starts with `<ID> `, record the issue as already delegated, say which session holds it, and move to the next issue.
4. **Launch.** Add a tab to the chosen session:

   ```bash
   rex window new -s <session_id> "<ID> <title>" -c "<repo>" --keep-open --focus=false --json -- sh -c "port enter '<gitBranchName>' && pi '<instruction>'"
   ```

   If the user chose a new session, create it instead, with the delegate in its first tab, and read the pane from `.initial_windows[0].block_ids[0]`:

   ```bash
   rex new "<session name>" -c "<repo>" --window "<ID> <title>" --keep-open --json -- sh -c "port enter '<gitBranchName>' && pi '<instruction>'"
   ```

   Shorten the title to about 40 characters for the label. Read the pane from `.block_ids[0]` of `rex window new`. `port enter` (rather than `port <branch>`) avoids collisions between branch names and Port subcommands. The command string is parsed by `sh`, so remove any single quote from interpolated values. Keep the command short: the instruction is the only prompt text it carries.
5. **Confirm.** Wait for the delegate to start by polling every few seconds, for up to about two minutes. Always pass `-s`, because a pane in another session is not found without it:

   ```bash
   rex block call -s <session_id> -b <pane> program_status | jq -r '.records[0].state // "none"'
   ```

   The step is done when the state is `working`. On `blocked`, `error`, or a timeout, read the tail with `rex capture -s <session_id> -b <pane> --trim | tail -n 30` and record what it shows. Report it as stuck and leave the tab as it is.

## Dispatch a PR review

Run these steps for each PR URL, one at a time.

1. **Resolve.** Parse `<owner>/<repo>#<n>` from the URL, then read the title with `gh pr view "<url>" --json title,url -q '.title'`. If it fails, record the failure and move to the next PR.
2. **Find or create the Reviews session.** Look for a session labeled exactly `Reviews` in `rex ls --json`.
   - Missing: `rex new Reviews -c "<review repo>" --window "<tab label>" --keep-open --json -- pi '<instruction>'`. Its first tab is the delegate. Skip step 3's tab creation and read the pane from `.initial_windows[0].block_ids[0]`.
   - Present: continue to step 3.
3. **Deduplicate, then add a tab.** Run `rex window ls -s Reviews --json`. If a window `label` starts with `<repo>#<n> `, record the PR as already delegated and move on. Otherwise:

   ```bash
   rex window new -s Reviews "<repo>#<n> <title>" -c "<review repo>" --keep-open --focus=false --json -- pi '<instruction>'
   ```

   Shorten the title to about 40 characters. Read the pane from `.block_ids[0]`. Rex passes each argument after `--` separately, so the instruction needs no shell quoting beyond staying free of single quotes.
4. **Confirm** the same way as an issue (`program_status` reaches `working`, passing `-s <Reviews session id>`).

The review instruction (`<url>` filled in), sent verbatim:

```text
Review pull request <url>. Read it with gh (gh pr view, gh pr diff, gh pr checks) and change nothing. Write me a summary in plain language for someone who has not seen the PR: what it changes and why, how it works, and what I should look at closely. Flag every blocker you spot (bugs, missing tests, risky or irreversible changes, failing checks, unresolved review threads), and for each give the evidence, why it matters, and what would fix it, following the explain-feedback skill and any technical-writing skill you have. Do not post to GitHub, push, or edit files. Then wait for me.
```

## Report

After the batch, send one line per item:

- Issue: the ID, the Linear title, the mode, the session it went into, and the outcome (`delegated`, `already delegated`, `stuck: <reason>`, or `failed: <reason>`). Link the title to its Linear URL.
- PR: `<repo>#<n>`, the PR title linked to its URL, `review`, and the same outcomes.

End with `Routing: <entries>` (the whole routing table, or `Routing: none` while it is empty), then `Dispatch mode on.`

## Guardrails

- After launch, a delegate belongs to the user. The dispatcher prompts, closes, moves, or refocuses a delegate's session or tab only when the user asks.
- Issue status, assignee, labels, and comments in Linear stay as they are. Review delegates never post to GitHub.
- Use a Port worktree for every issue delegate, whatever the repository's worktree policy says. The user chose isolation by invoking this skill. Review delegates read the PR through `gh` and need no worktree.
