{ config, repoDir, ... }:
{
  xdg.configFile."cmux".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/cmux";
}
