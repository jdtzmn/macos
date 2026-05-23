{ config, lib, repoDir, ... }:
{
  home.file.".agents/skills".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/opencode/skills";

  home.file.".agent-of-empires/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/agent-of-empires/config.toml";

  xdg.configFile."opencode".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/opencode";

  home.sessionVariables = {
    # Enables prettier markdown table rendering in OpenCode.
    # Temporary experimental flag; remove once this is stable upstream:
    # https://github.com/anomalyco/opencode/pull/10900
    OPENCODE_EXPERIMENTAL_MARKDOWN = "1";
  };

  home.activation.installPupSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v pup &>/dev/null; then
      $DRY_RUN_CMD pup skills install --dir "$HOME/.config/opencode/skills" || true
    fi
  '';
}
