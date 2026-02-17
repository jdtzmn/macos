---
description: Open the current branch's PR, new PR page, or repo in GitHub
---
Open GitHub for the current branch. Opens the pull request if one exists, the new pull request page if on an unmerged branch, or the repository page if on the default branch.

!`bash -lc 'set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh CLI not installed."
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: gh CLI not authenticated."
  exit 1
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
if [ -z "$BRANCH" ] || [ "$BRANCH" = "HEAD" ]; then
  echo "ERROR: Unable to determine current git branch."
  exit 1
fi

python3 - "$BRANCH" <<"PY"
import json
import re
import subprocess
import sys


branch = sys.argv[1]


def run(args):
    return subprocess.run(args, capture_output=True, text=True)


def open_url(url):
    return subprocess.run(["open", url], capture_output=True, text=True).returncode == 0


def run_stdout(args):
    proc = run(args)
    if proc.returncode != 0:
        return ""
    return proc.stdout.strip()


def run_json(args):
    raw = run_stdout(args)
    if not raw:
        return None
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return None


def open_pr(number, repo=None):
    cmd = ["gh", "pr", "view", str(number)]
    if repo:
        cmd.extend(["-R", repo])
    cmd.append("--web")
    return run(cmd).returncode == 0


def parse_repo_from_url(url):
    if not url:
        return ""
    candidate = url.strip()
    for prefix in (
        "git@github.com:",
        "ssh://git@github.com/",
        "https://github.com/",
        "http://github.com/",
    ):
        if candidate.startswith(prefix):
            candidate = candidate[len(prefix) :]
            break
    candidate = candidate.removesuffix(".git").rstrip("/")
    if re.fullmatch(r"[^/]+/[^/]+", candidate):
        return candidate
    return ""


default_branch = run_stdout(["gh", "repo", "view", "--json", "defaultBranchRef", "--jq", ".defaultBranchRef.name"])

direct = run_json(["gh", "pr", "view", "--json", "number,url"])
if isinstance(direct, dict) and direct.get("number"):
    number = direct["number"]
    if open_pr(number):
        print(f"Opened the pull request (#{number}) in a web browser.")
        raise SystemExit(0)


repo_candidates = []
seen_repos = set()


def add_repo(repo):
    if repo and repo not in seen_repos:
        seen_repos.add(repo)
        repo_candidates.append(repo)


add_repo(run_stdout(["gh", "repo", "view", "--json", "nameWithOwner", "--jq", ".nameWithOwner"]))
for remote in ("origin", "upstream"):
    add_repo(parse_repo_from_url(run_stdout(["git", "remote", "get-url", remote])))

if not repo_candidates:
    print("ERROR: Unable to determine current GitHub repository.")
    raise SystemExit(1)


owner_candidates = []
seen_owners = set()


def add_owner(owner):
    if owner and owner not in seen_owners:
        seen_owners.add(owner)
        owner_candidates.append(owner)


for repo in repo_candidates:
    add_owner(repo.split("/", 1)[0])
add_owner(run_stdout(["gh", "api", "user", "--jq", ".login"]))

head_candidates = []
seen_heads = set()


def add_head(head):
    if head and head not in seen_heads:
        seen_heads.add(head)
        head_candidates.append(head)


add_head(branch)
for owner in owner_candidates:
    add_head(f"{owner}:{branch}")

best = None
for repo in repo_candidates:
    for head in head_candidates:
        prs = run_json(
            [
                "gh",
                "pr",
                "list",
                "-R",
                repo,
                "--state",
                "open",
                "--head",
                head,
                "--json",
                "number,url,updatedAt",
            ]
        )
        if not isinstance(prs, list):
            continue
        for pr in prs:
            if not isinstance(pr, dict) or not pr.get("number"):
                continue
            updated = pr.get("updatedAt") or ""
            score = (updated, int(pr["number"]))
            if best is None or score > best["score"]:
                best = {
                    "repo": repo,
                    "number": int(pr["number"]),
                    "url": pr.get("url", ""),
                    "score": score,
                }

if best is not None:
    if open_pr(best["number"], best["repo"]):
        print(f"Opened the pull request (#{best['number']}) in a web browser.")
        raise SystemExit(0)

# No open PR found — fall back based on branch context.
repo = repo_candidates[0] if repo_candidates else ""

if not repo:
    print("ERROR: Unable to determine current GitHub repository.")
    raise SystemExit(1)

if default_branch and branch == default_branch:
    if run(["gh", "repo", "view", "-R", repo, "--web"]).returncode == 0:
        print("Opened the repository page in a web browser.")
    else:
        print("ERROR: Failed to open the repository page.")
        raise SystemExit(1)
else:
    compare_url = f"https://github.com/{repo}/compare/{branch}?expand=1"
    if open_url(compare_url):
        print("Opened the new pull request page in a web browser.")
    else:
        print("ERROR: Failed to open the new pull request page.")
        raise SystemExit(1)
PY'`

Return the shell output to the user. Do not attempt to open a browser or take any further action.
