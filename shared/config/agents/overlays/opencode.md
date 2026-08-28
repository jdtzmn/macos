# OpenCode-Specific Guidance

Layered on top of the shared personal development rules.

## Commit Packaging

- OpenCode provides a `committer` subagent. Use it for commit packaging only: staging files and creating commits.
- Do not delegate routine branch-management operations (switch/create/delete, merge, rebase, cherry-pick, fetch, pull, push) to `committer`; the primary agent runs those directly.
