{ config, repoDir, ... }:
{
  xdg.configFile."opencode".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/opencode";

  # Rex has its own tabs, but OpenCode's `tabs.mode: auto` only detects Herdr.
  programs.fish.functions.opencode = {
    description = "Launch OpenCode, hiding its session tabs inside Rex";
    body = ''
      if set -q REX_SESSION
          set -lx OPENCODE_CLI_CONFIG_CONTENT '{"tabs":{"mode":"off"}}'
      end
      command opencode $argv
    '';
  };
}
