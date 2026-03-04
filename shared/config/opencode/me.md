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

- Complete work in phases. Break larger tasks into logical, incremental steps and commit changes sequentially using the committer subagent after each phase.
- Never run `git add` or `git commit` from the primary agent. When staging/committing is needed, delegate immediately to the `committer` subagent.
- Commit intent triggers include requests like "commit this", "save changes", "checkpoint", or "WIP commit".

## Testing and Validation

- Add rules here.

## Git Workflow

- The primary agent may inspect git state (`git status`, `git diff`, `git log`, `git show`) but does not perform git write actions.
- The `committer` subagent is the only agent that stages files and creates commits.
