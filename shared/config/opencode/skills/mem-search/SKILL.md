---
name: mem-search
description: Search claude-mem persistent memory using MCP tools. Use when you need to recall previous observations, tool outputs, or session context from past claude-code or opencode sessions.
---

# mem-search

This skill enables searching persistent memory stored by claude-mem across both claude-code and opencode sessions.

## When to Use

Use this skill when:
- Asked about previous work, past sessions, or historical context
- Need to recall tool outputs or observations from earlier sessions
- Looking for patterns across multiple sessions
- Trying to avoid repeating work already done in a prior session

## 3-Layer Search Workflow

**ALWAYS follow this workflow. Never fetch full details without filtering first. This saves ~10x tokens.**

### Step 1: Search (get index with IDs)

Use the `search` tool to find relevant memories by query.
Returns a lightweight index with observation IDs (~50-100 tokens per result).

```
search(query="authentication implementation", limit=10)
```

### Step 2: Timeline (get context around results)

Use `timeline` with an anchor ID to get surrounding observations for context.
Pass either `anchor` (an observation ID) or `query` (auto-finds the anchor).

```
timeline(anchor=42, depth_before=3, depth_after=3)
```

### Step 3: Get Observations (fetch full details)

Use `get_observations` with the filtered IDs you actually need.
Only fetch IDs that are relevant after reviewing the index and timeline.

```
get_observations(ids=[42, 43, 44])
```

## Available MCP Tools

| Tool | Purpose |
|------|---------|
| `search` | Search memory by query. Returns index with IDs. Params: `query`, `limit`, `project`, `type`, `obs_type`, `dateStart`, `dateEnd`, `offset`, `orderBy` |
| `timeline` | Get context around a specific observation. Params: `anchor` (observation ID) OR `query` (finds anchor automatically), `depth_before`, `depth_after`, `project` |
| `get_observations` | Fetch full details for specific observation IDs. Params: `ids` (array, required), `orderBy`, `limit`, `project` |
| `save_memory` | Save a manual memory/observation. Params: `text` (required), `title`, `project` |

## Token Efficiency

| Step | Tokens per result |
|------|------------------|
| Step 1 (search) | ~50-100 tokens |
| Step 2 (timeline) | ~200-500 tokens |
| Step 3 (get_observations) | Full content |

Filter aggressively in steps 1 and 2 before calling `get_observations`. Fetching full details for unfiltered results wastes context.

## Example Workflows

**Find recent work on a feature:**
```
1. search(query="dark mode toggle", limit=5)
2. timeline(anchor=<id from step 1>)
3. get_observations(ids=[<relevant ids>])
```

**Check if a task was completed in a prior session:**
```
1. search(query="task completed authentication", project="my-project")
2. get_observations(ids=[<matching ids>])
```

**Find all observations from a date range:**
```
1. search(query="", dateStart="2026-01-01", dateEnd="2026-02-01", limit=20)
2. timeline(anchor=<id>)
3. get_observations(ids=[<filtered ids>])
```
