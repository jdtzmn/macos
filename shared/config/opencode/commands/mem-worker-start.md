---
description: Start the claude-mem memory worker
---

Start the claude-mem worker. The worker-service script is at:
!`echo "$(bun pm bin -g | sed 's|bin$|install/global|')/node_modules/claude-mem/plugin/scripts/worker-service.cjs"`

Run that path with bun and pass `start` as the argument. Then confirm the worker is healthy with `curl http://localhost:37777/health`.
