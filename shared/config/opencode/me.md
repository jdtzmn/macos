# Personal Development Process Rules

Use this file to capture my personal development workflow preferences.

## Working Style

- Add rules here.

## Secrets and .env Safety

- NEVER read, open, print, or request contents of any `.env` file (including `.env`, `.env.*`, and related secret env files).
- NEVER use commands or tools that would expose `.env` values in logs, output, diffs, prompts, or errors.
- If validation is needed, use non-revealing checks only (file existence, key-name presence, format/regex pass-fail) without exposing values.
- If a task would require reading secret values, stop and request a safe alternative instead.

## Code Changes

- Complete work in phases. Break larger tasks into logical, incremental steps.
- After completing each phase/step, commit the changes before moving on to the next step. Use the `committer` subagent for staging and creating commits.
- Additional commit intent triggers include requests like "commit this", "save changes", "checkpoint", or "WIP commit".

## Testing and Validation

- Add rules here.

## Git Workflow

- The primary agent may run normal git operations directly, including branch switch/create/delete, merge, rebase, cherry-pick, fetch, pull, and push (when requested).
- Do not delegate routine branch-management operations to `committer`.
- The `committer` subagent is for commit packaging only: staging files and creating commits.
