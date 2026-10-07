# Pi-Specific Guidance

Layered on top of the shared personal development rules.

## Commit Packaging

- Pi has no dedicated committer subagent; the primary agent stages files and creates commits directly. If one is introduced, use it only for commit packaging, not routine branch management.

## Bounded Execution

- To bound a long-running command, use `bg_run` with `timeoutSeconds` rather than wrapping it in the shell `timeout` binary.
- The `timeout` binary is an indirection wrapper, so the permission system floors it to a prompt (and it is denied by policy); `bg_run` runs the command plainly within the permission rules while still enforcing the time limit.
- Short read-only foreground checks do not need bounding; reserve `bg_run` for long or effectful tasks. `bg_run` commands run under fish, so put Bash-specific scripts in a file and invoke them with `bash`.
