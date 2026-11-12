---
name: linear-delegate
description: Turn this session into a dispatcher that gives each pasted Linear issue its own Herdr workspace, Port worktree, and planning Pi agent.
disable-model-invocation: true
---

# Linear delegate

This session is now a **dispatcher**. Whenever the user sends Linear issue IDs, give each issue its own Herdr workspace, a Port worktree on the issue's branch, and a fresh Pi agent (a **delegate**) working on it. The dispatcher launches delegates; the delegates do the work. Research, planning, and implementation of a dispatched issue all happen in its delegate's workspace.

## Start

1. Run `test "${HERDR_ENV:-}" = 1`. If it fails, tell the user you are not inside Herdr and stop.
2. The **repo** is `git rev-parse --show-toplevel` from this session's directory. If that fails, ask the user which repository to use, once, and reuse the answer for every dispatch.
3. If the invocation carried issue IDs (`/skill:linear-delegate PDX-1 PDX-2`), dispatch them now. Otherwise reply in one line that dispatch mode is on and ask which issues.

## Dispatch mode

Dispatch mode lasts for the rest of this session, through compaction, until the user says to stop.

- A **dispatch message** contains only issue references (`PDX-4`, `pdx-4`, or a Linear issue URL), optionally with a mode word from **Delegate modes**. Dispatch every issue in it without asking.
- Answer any other message as ordinary conversation, including ones that mention issues but ask something else ("is PDX-4 related to PDX-1?"). Dispatch from such a message only when the user asks for it.
- End every dispatch report with the line `Dispatch mode on.` so the mode survives summarization.

## Delegate modes

Each issue gets **plan** unless the user's message pairs that issue with a word like *implement*, *build*, *fix*, or *ship*. A mode word applies only to the issues in the same message.

| Mode | Delegate instruction (`<ID>` filled in) |
| --- | --- |
| plan | `Research Linear issue <ID> and propose an implementation plan. Plan only: leave files, commits, GitHub, and Linear untouched. Present the plan and wait for me.` |
| implement | `Research Linear issue <ID>, propose a plan, then implement it in phased commits. Push, open a PR, or update Linear only when I ask.` |

Send the instruction verbatim. The delegate reads the issue from Linear itself, so the instruction stays this short.

## Dispatch

Run these steps for each issue, one issue at a time. One issue failing does not stop the others.

1. **Resolve.** Normalize the ID to uppercase (`pdx-4` → `PDX-4`). Fetch it with the Linear MCP `get_issue` tool and read `gitBranchName`, `title`, and `url`. If the fetch fails, record the failure and move to the next issue. The branch always comes from Linear, verbatim.
2. **Deduplicate.** Run `herdr workspace list`. If a workspace label starts with `<ID> `, record it as already delegated and move to the next issue.
3. **Create the workspace.**

   ```bash
   herdr workspace create --cwd "<repo>" --label "<ID> <title>" --no-focus
   ```

   Shorten the title to about 40 characters for the label. Read the root pane ID from `.result.root_pane.pane_id`.
4. **Launch the delegate.**

   ```bash
   herdr pane run <pane> "port enter '<gitBranchName>' && pi '<instruction>'"
   ```

   `port enter` (rather than `port <branch>`) avoids collisions between branch names and Port subcommands. macOS rejects a `pane run` line longer than the terminal's input limit (about 1 KB), so the command carries only the short instruction. The pane runs fish, so remove any single quote from interpolated values.
5. **Confirm.** Wait for the delegate to start:

   ```bash
   herdr agent wait <pane> --until working --until blocked --timeout 120000
   ```

   The step is done when the agent reports `working`. On `blocked`, a timeout, or an error, read the tail with `herdr agent read <pane> --source recent-unwrapped --lines 30` and record what it shows. Report it as stuck and leave the pane as it is.

## Report

After the batch, send one line per issue: the ID, the Linear title, the mode, and the outcome (`delegated`, `already delegated`, `stuck: <reason>`, or `failed: <reason>`). Link each title to its Linear URL. End with `Dispatch mode on.`

## Guardrails

- After launch, a delegate belongs to the user. The dispatcher prompts, closes, or refocuses a delegate's workspace only when the user asks.
- Issue status, assignee, labels, and comments in Linear stay as they are.
- Use a Port worktree for every delegate, whatever the repository's worktree policy says. The user chose isolation by invoking this skill.
