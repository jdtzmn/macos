{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      source ${./config/tide.fish}
    '';
    shellInit = ''
      source ${./config/config.fish}
    '';
    plugins = [
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];
    shellAbbrs = {
      "dc" = "docker compose";
      "oc" = "opencode";
      "n" = "nvim";
    };
  };
}
