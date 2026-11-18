---
name: delegate
description: Turn this session into a dispatcher that gives each pasted Linear issue its own Rex session, Port worktree, and planning Pi agent, and sends each PR URL to a Pi agent in the Reviews session that summarizes it and flags blockers.
disable-model-invocation: true
---

# Delegate

This session is now a **dispatcher**. Whenever the user sends Linear issue IDs or PR URLs, hand each one to a fresh Pi agent (a **delegate**) in Rex. The dispatcher launches delegates; the delegates do the work.

- An **issue** gets its own Rex session, a Port worktree on the issue's branch, and a delegate that researches and plans in it.
- A **PR URL** gets a tab in the shared `Reviews` session and a delegate that summarizes the PR and flags blockers.

## Start

1. Run `test -n "$REX_SESSION"`. If it fails, tell the user you are not inside Rex and stop.
2. The **repo** is `git rev-parse --show-toplevel` from this session's directory. If that fails, use `$HOME` for reviews and ask the user which repository to use for issues, once, reusing the answer for every dispatch.
3. If the invocation carried issue IDs or PR URLs (`/skill:delegate PDX-1 https://github.com/o/r/pull/9`), dispatch them now. Otherwise reply in one line that dispatch mode is on and ask what to delegate.

## Dispatch mode

Dispatch mode lasts for the rest of this session, through compaction, until the user says to stop.

- A **dispatch message** contains only issue references (`PDX-4`, `pdx-4`, or a Linear issue URL) and PR URLs (`https://github.com/<owner>/<repo>/pull/<n>`), optionally with a mode word from **Issue modes**. Dispatch every item in it without asking. A PR URL is a review request only when the message is a dispatch message or the user asks to review it.
- Answer any other message as ordinary conversation, including ones that mention issues but ask something else ("is PDX-4 related to PDX-1?"). Dispatch from such a message only when the user asks for it.
- End every dispatch report with the line `Dispatch mode on.` so the mode survives summarization.

## Issue modes

Each issue gets **plan** unless the user's message pairs that issue with a word like *implement*, *build*, *fix*, or *ship*. A mode word applies only to the issues in the same message.

| Mode | Delegate instruction (`<ID>` filled in) |
| --- | --- |
| plan | `Research Linear issue <ID> and propose an implementation plan. Plan only: leave files, commits, GitHub, and Linear untouched. Present the plan and wait for me.` |
| implement | `Research Linear issue <ID>, propose a plan, then implement it in phased commits. Push, open a PR, or update Linear only when I ask.` |

Send the instruction verbatim. The delegate reads the issue from Linear itself, so the instruction stays this short.

## Dispatch an issue

Run these steps for each issue, one at a time. One issue failing does not stop the others.

1. **Resolve.** Normalize the ID to uppercase (`pdx-4` → `PDX-4`). Fetch it with the Linear MCP `get_issue` tool and read `gitBranchName`, `title`, and `url`. If the fetch fails, record the failure and move to the next issue. The branch always comes from Linear, verbatim.
2. **Deduplicate.** Run `rex ls --json`. If a session `label` starts with `<ID> `, record it as already delegated and move to the next issue.
3. **Launch.** Create the session with the delegate running in it:

   ```bash
   rex new "<ID> <title>" -c "<repo>" --window Agent --keep-open --json -- sh -c "port enter '<gitBranchName>' && pi '<instruction>'"
   ```

   Shorten the title to about 40 characters for the label. Read the session ID from `.session_id` and the pane from `.initial_windows[0].block_ids[0]`. `port enter` (rather than `port <branch>`) avoids collisions between branch names and Port subcommands. The command string is parsed by `sh`, so remove any single quote from interpolated values. Keep the command short: the instruction is the only prompt text it carries.
4. **Confirm.** Wait for the delegate to start by polling every few seconds, for up to about two minutes:

   ```bash
   rex block call -b <pane> program_status | jq -r '.records[0].state // "none"'
   ```

   The step is done when the state is `working`. On `blocked`, `error`, or a timeout, read the tail with `rex capture -b <pane> --trim | tail -n 30` and record what it shows. Report it as stuck and leave the session as it is.

## Dispatch a PR review

Run these steps for each PR URL, one at a time.

1. **Resolve.** Parse `<owner>/<repo>#<n>` from the URL, then read the title with `gh pr view "<url>" --json title,url -q '.title'`. If it fails, record the failure and move to the next PR.
2. **Find or create the Reviews session.** Look for a session labeled exactly `Reviews` in `rex ls --json`.
   - Missing: `rex new Reviews -c "<repo>" --window "<tab label>" --keep-open --json -- pi '<instruction>'`. Its first tab is the delegate. Skip step 3's tab creation and read the pane from `.initial_windows[0].block_ids[0]`.
   - Present: continue to step 3.
3. **Deduplicate, then add a tab.** Run `rex window ls -s Reviews --json`. If a window `label` starts with `<repo>#<n> `, record the PR as already delegated and move on. Otherwise:

   ```bash
   rex window new -s Reviews "<repo>#<n> <title>" -c "<repo path>" --keep-open --focus=false --json -- pi '<instruction>'
   ```

   Shorten the title to about 40 characters. Read the pane from `.block_ids[0]`. Rex passes each argument after `--` separately, so the instruction needs no shell quoting beyond staying free of single quotes.
4. **Confirm** the same way as an issue (`program_status` reaches `working`).

The review instruction (`<url>` filled in), sent verbatim:

```text
Review pull request <url>. Read it with gh (gh pr view, gh pr diff, gh pr checks) and change nothing. Write me a summary in plain language for someone who has not seen the PR: what it changes and why, how it works, and what I should look at closely. Flag every blocker you spot (bugs, missing tests, risky or irreversible changes, failing checks, unresolved review threads), and for each give the evidence, why it matters, and what would fix it, following the explain-feedback skill and any technical-writing skill you have. Do not post to GitHub, push, or edit files. Then wait for me.
```

## Report

After the batch, send one line per item:

- Issue: the ID, the Linear title, the mode, and the outcome (`delegated`, `already delegated`, `stuck: <reason>`, or `failed: <reason>`). Link the title to its Linear URL.
- PR: `<repo>#<n>`, the PR title linked to its URL, `review`, and the same outcomes.

End with `Dispatch mode on.`

## Guardrails

- After launch, a delegate belongs to the user. The dispatcher prompts, closes, or refocuses a delegate's session or tab only when the user asks.
- Issue status, assignee, labels, and comments in Linear stay as they are. Review delegates never post to GitHub.
- Use a Port worktree for every issue delegate, whatever the repository's worktree policy says. The user chose isolation by invoking this skill. Review delegates read the PR through `gh` and need no worktree.
