---
description: Prioritize your open PR queue quickly
agent: general
model: anthropic/claude-haiku-4-5
subtask: true
---
Build a PR priority queue using GitHub CLI snapshot data that has already been fetched for you.

Inputs:
- Repository: use `$1` when it matches `owner/repo`; otherwise default to `Standard-Template-Labs/repo`.

Snapshot context (already fetched; do not call MCP/`gh`/web tools yourself):
!`sh -lc 'set -euo pipefail; INPUT="${1:-}"; if printf "%s" "$INPUT" | grep -Eq "^[^/]+/[^/]+$"; then REPO="$INPUT"; else REPO="Standard-Template-Labs/repo"; fi; OWNER="${REPO%%/*}"; NAME="${REPO#*/}"; if ! command -v gh >/dev/null 2>&1; then echo "PR_SNAPSHOT_ERROR=gh CLI not installed"; exit 0; fi; if ! gh auth status >/dev/null 2>&1; then echo "PR_SNAPSHOT_ERROR=gh CLI not authenticated"; exit 0; fi; TMP="$(mktemp -d)"; trap "rm -rf \"$TMP\"" EXIT; (gh pr list -R "$REPO" --state open --search "author:@me" --limit 200 --json number --jq ".[].number" > "$TMP/authored_numbers.txt") & (gh pr list -R "$REPO" --state open --search "review-requested:@me" --limit 200 --json number --jq ".[].number" > "$TMP/reviewer_numbers.txt") & wait; NUMBERS="$(cat "$TMP/authored_numbers.txt" "$TMP/reviewer_numbers.txt" | awk "NF" | sort -nu)"; echo "PR_SNAPSHOT_REPO=$REPO"; echo "AUTHORED_PR_NUMBERS_BEGIN"; cat "$TMP/authored_numbers.txt"; echo "AUTHORED_PR_NUMBERS_END"; echo "REVIEW_REQUESTED_PR_NUMBERS_BEGIN"; cat "$TMP/reviewer_numbers.txt"; echo "REVIEW_REQUESTED_PR_NUMBERS_END"; if [ -z "$NUMBERS" ]; then echo "PR_SNAPSHOT_EMPTY=true"; exit 0; fi; for N in $NUMBERS; do (gh pr view "$N" -R "$REPO" --json number,title,url,isDraft,author,updatedAt,createdAt,mergeStateStatus,reviewDecision,reviewRequests,statusCheckRollup,reviews,comments > "$TMP/$N.core.json"; gh api --paginate "repos/$OWNER/$NAME/issues/$N/comments?per_page=100" > "$TMP/$N.issue_comments.json"; gh api --paginate "repos/$OWNER/$NAME/pulls/$N/comments?per_page=100" > "$TMP/$N.review_comments.json") & done; wait; for N in $NUMBERS; do echo "PR_${N}_CORE_JSON_BEGIN"; cat "$TMP/$N.core.json"; echo; echo "PR_${N}_CORE_JSON_END"; echo "PR_${N}_ISSUE_COMMENTS_JSON_BEGIN"; cat "$TMP/$N.issue_comments.json"; echo; echo "PR_${N}_ISSUE_COMMENTS_JSON_END"; echo "PR_${N}_REVIEW_COMMENTS_JSON_BEGIN"; cat "$TMP/$N.review_comments.json"; echo; echo "PR_${N}_REVIEW_COMMENTS_JSON_END"; done' -- "$1"`

Goal:
- Use the provided snapshot to prioritize all open PRs where I am either:
  - author (`author:@me`)
  - requested reviewer (`review-requested:@me`)
- Produce a markdown priority table sorted by what I should tackle first.

Required parsing flow:
1. If `PR_SNAPSHOT_ERROR=` is present, return exactly:
   - `GitHub CLI snapshot unavailable; cannot continue without gh.`
2. Read `PR_SNAPSHOT_REPO=...` for the repository name.
3. Read role sets from:
   - `AUTHORED_PR_NUMBERS_BEGIN ... AUTHORED_PR_NUMBERS_END`
   - `REVIEW_REQUESTED_PR_NUMBERS_BEGIN ... REVIEW_REQUESTED_PR_NUMBERS_END`
4. For each PR number in either role set, use:
   - `PR_<n>_CORE_JSON_BEGIN ... PR_<n>_CORE_JSON_END`
   - `PR_<n>_ISSUE_COMMENTS_JSON_BEGIN ... PR_<n>_ISSUE_COMMENTS_JSON_END`
   - `PR_<n>_REVIEW_COMMENTS_JSON_BEGIN ... PR_<n>_REVIEW_COMMENTS_JSON_END`
5. If `PR_SNAPSHOT_EMPTY=true`, output the no-PRs message.

Important:
- Do not make any additional network/tool calls. Use only the supplied snapshot blocks.

Ranking rules (highest priority first):
1. PRs requesting my review that are review-ready:
   - not draft
   - checks are green (or no required checks reported)
   - not obviously blocked by merge conflicts/mergeability issues (when available from `mergeStateStatus`)
2. My authored PRs with `CHANGES_REQUESTED`
3. My authored PRs with failing checks
4. My authored PRs with pending checks
5. My authored PRs approved with green checks (quick merge follow-up)
6. Everything else
7. Drafts last, unless they are review-requested and explicitly ready

Tiebreakers:
- Older `updatedAt` first within the same priority bucket.
- Then smaller PR number.

Interpretation rules:
- Role:
  - `Author` when I opened the PR
  - `Reviewer` when the PR is in the `review-requested:@me` result set
  - `Author+Reviewer` when both apply
- Reviews summary:
  - Compute latest review state per reviewer.
  - Show compact counts: `A:<approved> CR:<changes_requested> C:<commented>`.
- Title status dot (checks state, prefixed to title):
  - `🟢` success
  - `🟡` pending/in_progress
  - `🔴` failure/error/cancelled/timed_out
  - `⚪` unknown/no checks
- Review-ready gate for reviewer work:
  - Only treat reviewer PRs as top priority when non-draft and not blocked.
  - If checks are pending/failing, do not rank as review-ready.

Output:
- Return markdown only.
- Start with: `### PR Priority Queue (<repo>)` where `<repo>` comes from `PR_SNAPSHOT_REPO`.
- Then output a table with these columns:
  - `Rank`
  - `PR`
  - `Title` (with status dot prefix, e.g. `🟡 Improve parser retry logic`)
  - `Role`
  - `Draft`
  - `Reviews`
  - `Recommended Next Action`
  - `Why`
- Keep action text short and imperative.
- If no PRs are found, output:
  - `No open authored/review-requested PRs found in <repo>.`
