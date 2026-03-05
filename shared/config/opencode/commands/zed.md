---
description: Open Zed for the current directory
---
Open the Zed app for the current working directory.

!`bash -lc 'set -euo pipefail

if ! command -v open >/dev/null 2>&1; then
  echo "ERROR: open command not available."
  exit 1
fi

if ! open -a "Zed" .; then
  echo "ERROR: Failed to open Zed."
  exit 1
fi

echo "Opened Zed for the current directory."'`

Return the shell output to the user.
Zed was already opened by this command, so do not call any tool or run any additional command to open it again.
