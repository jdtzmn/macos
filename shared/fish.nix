{ pkgs, ... }:
{
  # We use `00` as a prefix to ensure that the tide configuration file is loaded before
  # the tide plugin itself.
  xdg.configFile."fish/conf.d/00-tide-config.fish".source = ./config/tide.fish;

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
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];
    shellAbbrs = {
      "dc" = "docker compose";
      "oc" = "opencode";
      "n" = "nvim";
      "up" = "docker compose up";
      "stop" = "docker compose stop";
      "down" = "docker compose down";
    };
  };
}
