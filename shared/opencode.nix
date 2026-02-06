{ config, repoDir, ... }:
{
  xdg.configFile."opencode".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/opencode";
}
