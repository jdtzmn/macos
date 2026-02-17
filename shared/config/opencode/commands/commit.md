---
description: Stage and commit current changes
agent: committer
model: anthropic/claude-haiku-4-5
subtask: true
---
Create a git commit for the current working tree changes.

If command argument `$1` is provided, treat it as the intended commit subject and use it when accurate.

Current git context:

git status:
!`git status 2>&1`

git diff HEAD:
!`git diff HEAD 2>&1`

Recent commits:
!`git log --oneline -10 2>&1`

Return:
- commit hash
- commit message
- files committed
- final git status
