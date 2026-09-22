{ config, repoDir, ... }:
{
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/herdr/config.toml";
}
