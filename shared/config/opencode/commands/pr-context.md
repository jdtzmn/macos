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
INLINE_RECENT_LIMIT=20
INLINE_COMMENT_CHAR_LIMIT=320
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

TMP="$(mktemp -d /tmp/pr-context.XXXXXX)"

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

OUTPUT_FILE="$TMP/pr_context.json"

python3 - "$TMP" "$REPO" "$BRANCH" "$PR_NUMBER" "$COMMENT_LIMIT" "$INLINE_RECENT_LIMIT" "$INLINE_COMMENT_CHAR_LIMIT" "$OUTPUT_FILE" <<"PY"
import json
import pathlib
import sys

tmp = pathlib.Path(sys.argv[1])
repo = sys.argv[2]
branch = sys.argv[3]
pr_number = sys.argv[4]
comment_limit = int(sys.argv[5])
inline_recent_limit = int(sys.argv[6])
inline_comment_char_limit = int(sys.argv[7])
output_file = pathlib.Path(sys.argv[8])


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


def slim_user(user):
    if isinstance(user, dict):
        return {"login": user.get("login", "unknown")}
    return user


def slim_review(r):
    return {
        "id": r.get("id"),
        "user": slim_user(r.get("user")),
        "state": r.get("state"),
        "body": r.get("body"),
        "submitted_at": r.get("submitted_at"),
    }


def slim_issue_comment(c):
    return {
        "id": c.get("id"),
        "user": slim_user(c.get("user")),
        "body": c.get("body"),
        "created_at": c.get("created_at"),
        "updated_at": c.get("updated_at"),
    }


def slim_review_comment(c):
    return {
        "id": c.get("id"),
        "in_reply_to_id": c.get("in_reply_to_id"),
        "user": slim_user(c.get("user")),
        "body": c.get("body"),
        "path": c.get("path"),
        "line": c.get("line"),
        "original_line": c.get("original_line"),
        "start_line": c.get("start_line"),
        "side": c.get("side"),
        "created_at": c.get("created_at"),
    }


def truncate_comment_body(body, char_limit):
    if not isinstance(body, str):
        return ""

    compact = " ".join(body.split())
    if char_limit <= 0 or len(compact) <= char_limit:
        return compact

    return compact[:char_limit].rstrip() + "..."


def recent_inline_comments(issue_comments_all, review_comments_all, limit, char_limit):
    combined = []

    for c in issue_comments_all:
        combined.append(
            {
                "type": "issue",
                "id": c.get("id"),
                "in_reply_to_id": None,
                "user": slim_user(c.get("user")),
                "body": truncate_comment_body(c.get("body"), char_limit),
                "path": None,
                "line": None,
                "created_at": c.get("created_at"),
            }
        )

    for c in review_comments_all:
        combined.append(
            {
                "type": "review",
                "id": c.get("id"),
                "in_reply_to_id": c.get("in_reply_to_id"),
                "user": slim_user(c.get("user")),
                "body": truncate_comment_body(c.get("body"), char_limit),
                "path": c.get("path"),
                "line": c.get("line"),
                "created_at": c.get("created_at"),
            }
        )

    combined = sorted(combined, key=lambda item: item.get("created_at") or "")
    if limit > 0:
        return combined[-limit:]
    return combined


core = load_json(tmp / "core.json", {})
reviews_raw = flatten_pages(load_json(tmp / "reviews.json", []))
issue_comments_all = flatten_pages(load_json(tmp / "issue_comments.json", []))
review_comments_all = flatten_pages(load_json(tmp / "review_comments.json", []))
checks = load_json(tmp / "checks.json", [])

issue_comments = latest(issue_comments_all, comment_limit)
review_comments = latest(review_comments_all, comment_limit)

reviews = [slim_review(r) for r in reviews_raw]
issue_comments = [slim_issue_comment(c) for c in issue_comments]
review_comments = [slim_review_comment(c) for c in review_comments]
recent_comments = recent_inline_comments(
    issue_comments_all,
    review_comments_all,
    inline_recent_limit,
    inline_comment_char_limit,
)

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

recent_meta = {
    "inline_recent_limit": inline_recent_limit,
    "inline_comment_char_limit": inline_comment_char_limit,
    "total_comments_considered": len(issue_comments_all) + len(review_comments_all),
    "recent_comments_included": len(recent_comments),
}

details = {
    "reviews": reviews,
    "issue_comments": issue_comments,
    "review_comments": review_comments,
}
with output_file.open("w", encoding="utf-8") as f:
    json.dump(details, f, indent=2)

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
print("<pr_recent_comments_meta>")
print(json.dumps(recent_meta, indent=2))
print("</pr_recent_comments_meta>")
print("<pr_recent_comments>")
print(json.dumps(recent_comments, indent=2))
print("</pr_recent_comments>")
print(f"<pr_context_file>{output_file}</pr_context_file>")
print("</pr_context>")
PY' -- "$1"`

Instructions:
- Use the XML-tagged snapshot as the source of truth for this pull request.
- If `<pr_found>false</pr_found>` appears, say there is no open PR for this branch and suggest opening one.
- Otherwise, give a concise PR context brief with:
  - current status (draft/review/checks)
  - blockers or requested changes
  - prioritized next actions, covering all relevant follow-ups
- Mention whether comment history is truncated via `<pr_meta>.comment_mode`.
- Always inspect `<pr_recent_comments>` before summarizing blockers and next actions.
- `<pr_recent_comments_meta>` includes the inline limits and how many comments were included.
- Inline comment bodies are truncated for context efficiency; if you need full text, read `<pr_context_file>`.
- The file at `<pr_context_file>` contains detailed review and comment data (reviews, issue comments, review comments) as JSON. Use `Read` or `Grep` on that file to inspect specific comments when needed.
- Each comment includes an `id` field. Review comments also include `in_reply_to_id` for threading. Use these IDs when replying to comments via `gh api`.
