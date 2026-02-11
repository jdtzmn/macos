---
description: Prioritize your open PR queue (MCP only)
agent: general
subtask: true
---
Use GitHub MCP tools only. Do not use `gh` commands, do not use Bash for GitHub access, and do not use web fetchers.

If GitHub MCP tools are unavailable, fail immediately with:
`GitHub MCP unavailable; cannot continue without MCP.`

Inputs:
- Repository: use `$1` when it matches `owner/repo`; otherwise default to `Standard-Template-Labs/repo`.

Goal:
- Fetch all open PRs in the target repo where I am either:
  - author (`author:@me`)
  - requested reviewer (`review-requested:@me`)
- For each PR, read `get`, `get_status`, and `get_reviews`.
- Run those per-PR state reads in parallel.
- Produce a markdown priority table sorted by what I should tackle first.

Required MCP flow:
1. Run these `search_pull_requests` calls in parallel:
   - `is:pr is:open repo:<repo> author:@me`
   - `is:pr is:open repo:<repo> review-requested:@me`
2. Merge and deduplicate PRs by number.
3. For each PR number, run these `pull_request_read` calls in parallel:
   - `method: get`
   - `method: get_status`
   - `method: get_reviews`

Ranking rules (highest priority first):
1. PRs requesting my review that are review-ready:
   - not draft
   - checks are green (or no required checks reported)
   - not obviously blocked by merge conflicts/mergeability issues (when available from `get`)
2. My authored PRs with `CHANGES_REQUESTED`
3. My authored PRs with failing checks
4. My authored PRs with pending checks
5. My authored PRs approved with green checks (quick merge follow-up)
6. Everything else
7. Drafts last, unless they are review-requested and explicitly ready

Tiebreakers:
- Older `updated_at` first within the same priority bucket.
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
- Start with: `### PR Priority Queue (<repo>)`
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
