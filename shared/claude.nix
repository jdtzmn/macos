{ config, lib, ... }:
let
  home = config.home.homeDirectory;
in
{
  # Leave Claude's own files (including its synced skills) under its control.
  # Link individual shared skills so additions appear on the next activation.
  home.activation.linkSharedClaudeGuidance = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    rules=${lib.escapeShellArg "${home}/.claude/rules"}
    guidance=${lib.escapeShellArg "${home}/.config/agents/personal-base.md"}
    guidance_link="$rules/personal-base.md"

    if [ ! -f "$guidance" ]; then
      echo "Skipping Claude guidance: $guidance is missing" >&2
    elif [ -e "$guidance_link" ] || [ -L "$guidance_link" ]; then
      if [ ! -L "$guidance_link" ] || [ "$(readlink "$guidance_link")" != "$guidance" ]; then
        echo "Preserving existing Claude rule: $guidance_link" >&2
      fi
    elif [ -e "$rules" ] && [ ! -d "$rules" ]; then
      echo "Skipping Claude guidance: $rules is not a directory" >&2
    else
      $DRY_RUN_CMD mkdir -p "$rules"
      $DRY_RUN_CMD ln -s "$guidance" "$guidance_link"
    fi

    shared_skills=${lib.escapeShellArg "${home}/.agents/skills"}
    claude_skills=${lib.escapeShellArg "${home}/.claude/skills"}
    if [ ! -d "$shared_skills" ]; then
      echo "Skipping Claude skills: $shared_skills is missing" >&2
    elif [ -L "$claude_skills" ] || { [ -e "$claude_skills" ] && [ ! -d "$claude_skills" ]; }; then
      echo "Skipping Claude skills: $claude_skills is not an independent directory" >&2
    else
      $DRY_RUN_CMD mkdir -p "$claude_skills"
      for skill in "$shared_skills"/*; do
        [ -f "$skill/SKILL.md" ] || continue
        name="''${skill##*/}"
        [ "$name" = synced ] && continue
        target="$claude_skills/$name"
        if [ -e "$target" ] || [ -L "$target" ]; then
          if [ ! -L "$target" ] || [ "$(readlink "$target")" != "$skill" ]; then
            echo "Preserving existing Claude skill: $target" >&2
          fi
          continue
        fi
        $DRY_RUN_CMD ln -s "$skill" "$target"
      done
    fi
  '';
}
