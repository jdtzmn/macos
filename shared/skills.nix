{ config, lib, repoDir, ... }:
{
  # ~/.agents/skills is the shared, Agent-Skills-standard-compliant location
  # that any compliant coding agent (Pi, OpenCode, etc.) discovers skills
  # from. It happens to also resolve to the same physical directory as
  # ~/.config/opencode/skills, but this wiring is intentionally
  # agent-agnostic and does not belong to any single agent's module.
  home.file.".agents/skills".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/opencode/skills";

  # Installs pup's Datadog CLI skills into the shared ~/.agents/skills dir
  # so they're discoverable by any Agent-Skills-standard-compliant coding
  # agent, not just OpenCode. --type=skill limits this to the 9 focused
  # dd-* skills and skips pup's ~48 broader "agent" entries to keep
  # context lean.
  home.activation.installPupSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v pup &>/dev/null; then
      $DRY_RUN_CMD pup skills install --type=skill --dir "$HOME/.agents/skills" --yes || true
    fi
  '';
}
