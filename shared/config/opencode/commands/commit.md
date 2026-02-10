---
description: Stage and commit current changes
agent: committer
subtask: true
---
Create a git commit for the current working tree changes.

If command argument `$1` is provided, treat it as the intended commit subject and use it when accurate.

Return:
- commit hash
- commit message
- files committed
- final git status
