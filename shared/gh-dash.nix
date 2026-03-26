{ config, repoDir, ... }:
{
  xdg.configFile."gh-dash/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/gh-dash/config.yml";
}
