{ pkgs, ... }:
{
  home.file.".config/wezterm/wezterm.lua".source = ./config/wezterm.lua;
}
