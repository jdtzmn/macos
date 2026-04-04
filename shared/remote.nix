{ config, repoDir, ... }:
{
  home.file.".local/bin/remote".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/remote";
}
