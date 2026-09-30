# Shepherd ledger

`scripts/shepherd` is the only writer. It keeps runtime state outside the repo in
`${HERDR_SHEPHERD_STATE_DIR:-${XDG_STATE_HOME:-~/.local/state}/herdr-shepherd}` (print it with
`shepherd path`):

- `ledger.json`: current state, rewritten atomically on every change.
- `events.jsonl`: append-only audit trail of every outcome and setting change.

## `ledger.json`

```json
{
  "version": 1,
  "mode": "observe",
  "policy": { "cooldown_minutes": 10, "max_nudges": 2, "window_minutes": 120, "triage_limit": 5 },
  "last_sweep": "2026-09-30T19:01:42Z",
  "agents": {
    "<agent session path, or pane id when Herdr reports none>": {
      "pane_id": "wQ:p1",
      "workspace_id": "wQ",
      "title": "Resolve Merge Conflicts for Onboarding Persona PR #11922 - …",
      "cwd": "/Users/jacob/Documents/GitHub/repo/.port/trees/…",
      "focused": false,
      "progress": "100% · Done",
      "status": "idle",
      "state_change_seq": 2639,
      "status_since": "2026-09-30T18:40:00Z",
      "last_seen": "2026-09-30T19:01:42Z",
      "gone_at": null,
      "auto_nudge": false,
      "ignore": false,
      "triaged_seq": 2639,
      "nudges": ["2026-09-30T18:52:00Z"],
      "attention": { "action": "suggest", "class": "continue-plan", "message": "…", "seq": 2639, "at": "…" }
    }
  }
}
```

- **Key**: the agent's session file, so a pane moving between workspaces keeps its entry and a new
  session in the same pane starts fresh.
- **Observed fields** (`pane_id` through `last_seen`) are copied from `herdr agent list` on every
  sweep. `status_since` is when a sweep first saw the current state, so it is accurate to the sweep
  interval.
- **Triage is once per state change**: a row shows `TRIAGE` while its status is idle, done,
  blocked, or unknown and `triaged_seq` differs from `state_change_seq`. Any `shepherd log` sets
  `triaged_seq`.
- **`attention`** holds an open suggestion or escalation and clears itself as soon as the agent's
  state changes.
- **`nudges`** holds automatic-nudge timestamps inside the rolling window; user-approved `send`s
  are not counted.
- **Gone agents** get `gone_at` and are dropped after seven days.

## Policy

Edit `policy` in `ledger.json` to tune it:

| Key | Meaning |
| --- | --- |
| `cooldown_minutes` | Minimum gap between automatic nudges to one agent. |
| `max_nudges` | Automatic nudges allowed per agent within the window before escalating. |
| `window_minutes` | Rolling window for `max_nudges`. |
| `triage_limit` | Most rows to triage per sweep; the remainder wait for the next sweep. |

## `events.jsonl`

One object per line: `{ts, action, key, pane_id, class, message}`. `action` is one of `park`,
`suggest`, `escalate`, `nudge`, `send`, `baseline`, `mode`, `auto_nudge`, or `ignore`.
