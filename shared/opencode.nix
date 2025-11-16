{ pkgs, ... }:
{
  home.file.".config/opencode/opencode.jsonc".source = ./config/opencode/opencode.jsonc;
  home.file.".config/opencode/plugin/notification.js".source = ./config/opencode/plugin/notification.js;
}
