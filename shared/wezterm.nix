{ config, repoDir, ... }:
{
  xdg.configFile."wezterm/wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/wezterm.lua";
}
