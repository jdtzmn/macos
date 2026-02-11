---
description: Load current branch PR context into this chat
---
Load pull request context for the current git branch and inject it for this primary agent conversation.

Inputs:
- Optional mode `$1`:
  - `full`: include all issue comments and review comments
  - default: include latest 100 issue comments and latest 100 review comments

Snapshot context:
!`sh -lc 'set -euo pipefail

MODE="${1:-latest}"
COMMENT_LIMIT=100
if [ "$MODE" = "full" ]; then
  COMMENT_LIMIT=0
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "<pr_context_error>gh CLI not installed</pr_context_error>"
  exit 0
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "<pr_context_error>gh CLI not authenticated</pr_context_error>"
  exit 0
fi

REPO="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)"
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

if [ -z "$REPO" ]; then
  echo "<pr_context_error>unable to resolve current GitHub repository</pr_context_error>"
  exit 0
fi

if [ -z "$BRANCH" ] || [ "$BRANCH" = "HEAD" ]; then
  echo "<pr_context_error>unable to resolve current git branch</pr_context_error>"
  exit 0
fi

PR_NUMBER="$(gh pr list -R "$REPO" --state open --head "$BRANCH" --json number,updatedAt --jq "sort_by(.updatedAt) | last | .number // empty" 2>/dev/null || true)"

if [ -z "$PR_NUMBER" ]; then
  echo "<pr_context>"
  echo "<repo>$REPO</repo>"
  echo "<branch>$BRANCH</branch>"
  echo "<pr_found>false</pr_found>"
  echo "<note>No open pull request found for current branch.</note>"
  echo "</pr_context>"
  exit 0
fi

OWNER="${REPO%%/*}"
NAME="${REPO#*/}"

TMP="$(mktemp -d)"
trap "rm -rf \"$TMP\"" EXIT

(
  gh pr view "$PR_NUMBER" -R "$REPO" \
    --json number,title,body,url,state,isDraft,author,headRefName,baseRefName,createdAt,updatedAt,mergeStateStatus,reviewDecision,reviewRequests,labels,assignees,statusCheckRollup,commits \
    > "$TMP/core.json"
) &

(
  gh api --paginate --slurp "repos/$OWNER/$NAME/pulls/$PR_NUMBER/reviews?per_page=100" > "$TMP/reviews.json"
) &

(
  gh api --paginate --slurp "repos/$OWNER/$NAME/issues/$PR_NUMBER/comments?per_page=100" > "$TMP/issue_comments.json"
) &

(
  gh api --paginate --slurp "repos/$OWNER/$NAME/pulls/$PR_NUMBER/comments?per_page=100" > "$TMP/review_comments.json"
) &

(
  gh pr checks "$PR_NUMBER" -R "$REPO" --json name,state,link,bucket,event,workflow > "$TMP/checks.json" 2>/dev/null || printf "[]\n" > "$TMP/checks.json"
) &

wait

python3 - "$TMP" "$REPO" "$BRANCH" "$PR_NUMBER" "$COMMENT_LIMIT" <<"PY"
import json
import pathlib
import sys

tmp = pathlib.Path(sys.argv[1])
repo = sys.argv[2]
branch = sys.argv[3]
pr_number = sys.argv[4]
comment_limit = int(sys.argv[5])


def load_json(path: pathlib.Path, default):
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return default


def latest(items, limit):
    if limit <= 0:
        return items

    def key(item):
        for field in ("created_at", "submitted_at", "updated_at"):
            value = item.get(field)
            if isinstance(value, str):
                return value
        return ""

    return sorted(items, key=key)[-limit:]


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


core = load_json(tmp / "core.json", {})
reviews = flatten_pages(load_json(tmp / "reviews.json", []))
issue_comments_all = flatten_pages(load_json(tmp / "issue_comments.json", []))
review_comments_all = flatten_pages(load_json(tmp / "review_comments.json", []))
checks = load_json(tmp / "checks.json", [])

issue_comments = latest(issue_comments_all, comment_limit)
review_comments = latest(review_comments_all, comment_limit)

comment_mode = "full" if comment_limit <= 0 else f"latest_{comment_limit}"

meta = {
    "repo": repo,
    "branch": branch,
    "pr_number": int(pr_number),
    "comment_mode": comment_mode,
    "issue_comments_total": len(issue_comments_all),
    "issue_comments_included": len(issue_comments),
    "review_comments_total": len(review_comments_all),
    "review_comments_included": len(review_comments),
}

print("<pr_context>")
print("<pr_found>true</pr_found>")
print("<pr_meta>")
print(json.dumps(meta, indent=2))
print("</pr_meta>")
print("<pr_core>")
print(json.dumps(core, indent=2))
print("</pr_core>")
print("<pr_checks>")
print(json.dumps(checks, indent=2))
print("</pr_checks>")
print("<pr_reviews>")
print(json.dumps(reviews, indent=2))
print("</pr_reviews>")
print("<pr_issue_comments>")
print(json.dumps(issue_comments, indent=2))
print("</pr_issue_comments>")
print("<pr_review_comments>")
print(json.dumps(review_comments, indent=2))
print("</pr_review_comments>")
print("</pr_context>")
PY' -- "$1"`

Instructions:
- Use the XML-tagged snapshot as the source of truth for this pull request.
- If `<pr_found>false</pr_found>` appears, say there is no open PR for this branch and suggest opening one.
- Otherwise, give a concise PR context brief with:
  - current status (draft/review/checks)
  - blockers or requested changes
  - top 3 next actions
- Mention whether comment history is truncated via `<pr_meta>.comment_mode`.
