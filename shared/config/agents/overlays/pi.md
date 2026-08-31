# Pi-Specific Guidance

Layered on top of the shared personal development rules.

## Commit Packaging

- Pi has no dedicated committer subagent. The primary agent stages files and creates commits directly.
- If a committer-style subagent is ever introduced, use it for commit packaging only, never for routine branch-management operations.

## Bounded Execution

- To bound a long-running command, use `bg_run` with `timeoutSeconds` rather than wrapping it in the shell `timeout` binary.
- The `timeout` binary is an indirection wrapper, so the permission system floors it to a prompt (and it is denied by policy); `bg_run` runs the command plainly within the permission rules while still enforcing the time limit.
- Short read-only foreground checks do not need bounding at all; reserve `bg_run` for long or effectful tasks.
