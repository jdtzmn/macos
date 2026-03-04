---
description: Stop the claude-mem memory worker
---

Stop the claude-mem worker. The worker-service script is at:
!`echo "$(bun pm bin -g | sed 's|bin$|install/global|')/node_modules/claude-mem/plugin/scripts/worker-service.cjs"`

Run that path with bun and pass `stop` as the argument.
