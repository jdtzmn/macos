# Personal Development Process Rules

Use this file to capture my personal development workflow preferences.

## Working Style

- For any non-trivial coding task, use a phased workflow by default.
- Break implementation work into small, logical, incremental steps.
- After each completed phase, run the smallest relevant validation you can, then create a commit before starting the next phase.
- Skip phase-by-phase commits only for trivial single-change tasks, read-only work, or when the user explicitly asks for one final commit.

## Secrets and .env Safety

- NEVER read, open, print, or request contents of any `.env` file (including `.env`, `.env.*`, and related secret env files).
- NEVER use commands or tools that would expose `.env` values in logs, output, diffs, prompts, or errors.
- If validation is needed, use non-revealing checks only (file existence, key-name presence, format/regex pass-fail) without exposing values.
- If a task would require reading secret values, stop and request a safe alternative instead.

## Code Changes

- Treat phased implementation as the default for multi-step work.
- Complete work in phases. Break larger tasks into logical, incremental steps.
- After completing each phase/step, validate the change, then commit it before moving on to the next step. Use the `committer` subagent for staging and creating commits.
- Additional commit intent triggers include requests like "commit this", "save changes", "checkpoint", or "WIP commit".

## Testing and Validation

- Prefer the smallest relevant validation for the current phase before committing.
- If a full test suite or build is expensive, run a targeted check first and note any broader validation that still remains.

## Git Workflow

- The primary agent may run normal git operations directly, including branch switch/create/delete, merge, rebase, cherry-pick, fetch, pull, and push (when requested).
- Do not delegate routine branch-management operations to `committer`.
- The `committer` subagent is for commit packaging only: staging files and creating commits.

## GitHub Communication

- When posting any text to GitHub on my behalf, append the following footer on its own line at the end of the message body:

      _(Drafted by Jacob's coding agent on his behalf)_

- Apply to all GitHub text output, including but not limited to:
  - PR descriptions (`gh pr create --body`, `gh pr edit --body`)
  - PR comments (`gh pr comment`)
  - Issue descriptions and comments (`gh issue create`, `gh issue comment`)
  - PR reviews and review replies (`gh pr review`, review comment threads)
  - Equivalent GitHub MCP tools (`github_*` issue/PR comment and review actions)
- Do NOT add the footer to:
  - Git commit messages or commit trailers
  - PR or issue titles
  - Code, code suggestions, or file contents inside diffs
  - Messages that already contain an equivalent attribution
- If I explicitly ask to omit the footer for a specific message, omit it.
- Place the footer as the final line, separated from the preceding content by one blank line.
