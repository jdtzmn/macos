{ config, repoDir, ... }:
{
  home.file.".pi/agent".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/pi";
}
