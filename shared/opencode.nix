{ config, repoDir, ... }:
{
  xdg.configFile."opencode".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/opencode";

  home.sessionVariables = {
    # Enables prettier markdown table rendering in OpenCode.
    # Temporary experimental flag; remove once this is stable upstream:
    # https://github.com/anomalyco/opencode/pull/10900
    OPENCODE_EXPERIMENTAL_MARKDOWN = "1";
  };
}
