{ config, repoDir, ... }:
{
  xdg.configFile."rex/init.lua".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/rex/init.lua";
}
