---
description: Prioritize your open PR queue quickly
agent: general
model: anthropic/claude-haiku-4-5
subtask: true
---
Build a PR priority queue using GitHub CLI snapshot data that has already been fetched for you.

Inputs:
- Repository: use `$1` when it matches `owner/repo`; otherwise auto-detect from the local git repository.

Snapshot context (already fetched; do not call MCP/`gh`/web tools yourself):
!`sh -lc 'set -euo pipefail; INPUT="${1:-}"; REPO=""; if printf "%s" "$INPUT" | grep -Eq "^[^/]+/[^/]+$"; then REPO="$INPUT"; fi; if [ -z "$REPO" ]; then ORIGIN_URL="$(git remote get-url origin 2>/dev/null || true)"; CANDIDATE="$ORIGIN_URL"; case "$CANDIDATE" in git@github.com:*) CANDIDATE="${CANDIDATE#git@github.com:}" ;; ssh://git@github.com/*) CANDIDATE="${CANDIDATE#ssh://git@github.com/}" ;; https://github.com/*) CANDIDATE="${CANDIDATE#https://github.com/}" ;; http://github.com/*) CANDIDATE="${CANDIDATE#http://github.com/}" ;; esac; CANDIDATE="${CANDIDATE%.git}"; CANDIDATE="${CANDIDATE%/}"; if printf "%s" "$CANDIDATE" | grep -Eq "^[^/]+/[^/]+$"; then REPO="$CANDIDATE"; fi; fi; if [ -z "$REPO" ] && command -v gh >/dev/null 2>&1; then REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)"; fi; if [ -z "$REPO" ]; then echo "<pr_priority_error>unable to resolve current GitHub repository</pr_priority_error>"; exit 0; fi; if ! command -v gh >/dev/null 2>&1; then echo "<pr_priority_error>gh CLI not installed</pr_priority_error>"; exit 0; fi; if ! gh auth status >/dev/null 2>&1; then echo "<pr_priority_error>gh CLI not authenticated</pr_priority_error>"; exit 0; fi; OWNER="${REPO%%/*}"; NAME="${REPO#*/}"; TMP="$(mktemp -d)"; trap "rm -rf \"$TMP\"" EXIT; (gh pr list -R "$REPO" --state open --search "author:@me" --limit 200 --json number --jq ".[].number" > "$TMP/authored_numbers.txt") & (gh pr list -R "$REPO" --state open --search "review-requested:@me" --limit 200 --json number --jq ".[].number" > "$TMP/reviewer_numbers.txt") & wait; NUMBERS="$(cat "$TMP/authored_numbers.txt" "$TMP/reviewer_numbers.txt" | awk "NF" | sort -nu)"; if [ -n "$NUMBERS" ]; then for N in $NUMBERS; do (gh pr view "$N" -R "$REPO" --json number,title,url,isDraft,author,updatedAt,createdAt,mergeStateStatus,reviewDecision,reviewRequests,statusCheckRollup,reviews,comments > "$TMP/$N.core.json"; gh api --paginate --slurp "repos/$OWNER/$NAME/issues/$N/comments?per_page=100" > "$TMP/$N.issue_comments.json"; gh api --paginate --slurp "repos/$OWNER/$NAME/pulls/$N/comments?per_page=100" > "$TMP/$N.review_comments.json") & done; wait; fi; python3 - "$TMP" "$REPO" <<"PY"
import json
import pathlib
import sys

tmp = pathlib.Path(sys.argv[1])
repo = sys.argv[2]


def load_json(path: pathlib.Path, default):
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return default


def read_number_lines(path: pathlib.Path):
    if not path.exists():
        return []
    values = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            values.append(int(line))
        except ValueError:
            pass
    return values


def flatten_pages(value):
    if not isinstance(value, list):
        return []
    flattened = []
    for page in value:
        if isinstance(page, list):
            flattened.extend(page)
        else:
            flattened.append(page)
    return flattened


def cdata(text: str):
    return "<![CDATA[" + text.replace("]]>", "]]]]><![CDATA[>") + "]]>"


authored = sorted(set(read_number_lines(tmp / "authored_numbers.txt")))
review_requested = sorted(set(read_number_lines(tmp / "reviewer_numbers.txt")))
numbers = sorted(set(authored + review_requested))

print("<pr_priority_snapshot>")
print(f"<repo>{repo}</repo>")
print(f"<pr_priority_empty>{str(len(numbers) == 0).lower()}</pr_priority_empty>")
print("<authored_pr_numbers_json>")
print(cdata(json.dumps(authored)))
print("</authored_pr_numbers_json>")
print("<review_requested_pr_numbers_json>")
print(cdata(json.dumps(review_requested)))
print("</review_requested_pr_numbers_json>")
print("<pr_items>")

for number in numbers:
    core = load_json(tmp / f"{number}.core.json", {})
    issue_comments = flatten_pages(load_json(tmp / f"{number}.issue_comments.json", []))
    review_comments = flatten_pages(load_json(tmp / f"{number}.review_comments.json", []))

    print("<pr_item>")
    print(f"<number>{number}</number>")
    print(f"<is_authored>{str(number in authored).lower()}</is_authored>")
    print(f"<is_review_requested>{str(number in review_requested).lower()}</is_review_requested>")
    print("<pr_core_json>")
    print(cdata(json.dumps(core, indent=2)))
    print("</pr_core_json>")
    print("<pr_issue_comments_json>")
    print(cdata(json.dumps(issue_comments, indent=2)))
    print("</pr_issue_comments_json>")
    print("<pr_review_comments_json>")
    print(cdata(json.dumps(review_comments, indent=2)))
    print("</pr_review_comments_json>")
    print("</pr_item>")

print("</pr_items>")
print("</pr_priority_snapshot>")
PY' -- "$1"`

Goal:
- Use the provided snapshot to prioritize all open PRs where I am either:
  - author (`author:@me`)
  - requested reviewer (`review-requested:@me`)
- Produce a markdown priority table sorted by what I should tackle first.

Required parsing flow:
1. If `<pr_priority_error>` is present, return exactly:
   - `GitHub CLI snapshot unavailable; cannot continue without gh.`
2. Read repository from `<repo>`.
3. Read role sets from:
   - `<authored_pr_numbers_json>`
   - `<review_requested_pr_numbers_json>`
4. For each `<pr_item>`, use:
   - `<number>`
   - `<is_authored>` and `<is_review_requested>`
   - `<pr_core_json>`
   - `<pr_issue_comments_json>`
   - `<pr_review_comments_json>`
5. If `<pr_priority_empty>true</pr_priority_empty>`, output the no-PRs message.

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
- Start with: `### PR Priority Queue (<repo>)` where `<repo>` comes from `<repo>`.
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
