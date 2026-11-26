{ config, repoDir, ... }:
{
  home.file.".octet".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/octet";
}
