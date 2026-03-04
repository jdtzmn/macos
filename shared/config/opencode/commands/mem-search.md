---
description: Search claude-mem persistent memory
---

Search my claude-mem persistent memory for: $ARGUMENTS

Use the claude-mem MCP search tool. Follow the 3-layer workflow:
1. search(query="$ARGUMENTS") to get an index with IDs
2. timeline(anchor=ID) for context around interesting results
3. get_observations([IDs]) for full details

Present results with observation IDs, titles, and relevant content.
