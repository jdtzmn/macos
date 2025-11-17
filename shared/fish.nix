{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    shellInit = ''
      source ${./config/config.fish}
    '';
    plugins = [
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
    ];
    shellAbbrs = {
      "dc" = "docker compose";
      "oc" = "opencode";
      "n" = "nvim";
    };
  };
}
