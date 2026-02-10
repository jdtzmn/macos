---
description: Draft a PR body from branch commits
agent: general
subtask: true
---
Create a pull request description from the commits on this branch.

Base branch selection (in order):
1. Use command argument `$1` when provided.
2. Else use the first existing ref from: `origin/main`, `origin/master`, `origin/dev`.
3. Else use the remote default branch from `origin/HEAD`.
4. Else use the first existing local ref from: `main`, `master`, `dev`.
5. Else fallback to `HEAD~10` (or `HEAD~1` if needed).

Repository context:
!`sh -lc 'USER_BASE="$1"; BASE=""; if [ -n "$USER_BASE" ] && git rev-parse --verify --quiet "$USER_BASE" >/dev/null; then BASE="$USER_BASE"; fi; if [ -z "$BASE" ]; then for ref in origin/main origin/master origin/dev; do if git rev-parse --verify --quiet "$ref" >/dev/null; then BASE="$ref"; break; fi; done; fi; if [ -z "$BASE" ]; then DEFAULT_REMOTE="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"; if [ -n "$DEFAULT_REMOTE" ] && git rev-parse --verify --quiet "$DEFAULT_REMOTE" >/dev/null; then BASE="$DEFAULT_REMOTE"; fi; fi; if [ -z "$BASE" ]; then for ref in main master dev; do if git rev-parse --verify --quiet "$ref" >/dev/null; then BASE="$ref"; break; fi; done; fi; if [ -z "$BASE" ]; then if git rev-parse --verify --quiet HEAD~10 >/dev/null; then BASE="HEAD~10"; else BASE="HEAD~1"; fi; fi; echo "BASE_REF=$BASE"; echo "RANGE=${BASE}..HEAD"; echo; echo "COMMITS:"; git log --oneline --no-decorate "${BASE}..HEAD" || true; echo; echo "FILES:"; git diff --name-status "${BASE}...HEAD" || true; echo; echo "DIFFSTAT:"; git diff --stat "${BASE}...HEAD" || true'`

Return only a single fenced code block that uses triple tildes (`~~~`) as the outer fence.
Inside it, include a literal triple-backtick markdown block using this template:

~~~text
```markdown
## Summary
- <key change 1>
- <key change 2>

## Testing
- <what was tested>
- <result>

## Risks
- <known risk or "None noted">
- <rollout/mitigation note if applicable>
```
~~~

Guidelines:
- Keep it concise and specific to the included commits.
- Prefer user-facing impact and intent over low-level implementation detail.
- If testing evidence is not present, explicitly say it was not run or not found.
