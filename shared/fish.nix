{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    shellInit = ''
      source ${./config/config.fish}
      source ${./config/tide.fish}
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
