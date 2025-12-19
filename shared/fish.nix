{ pkgs, ... }:
{
  # We use `00` as a prefix to ensure that the tide configuration file is loaded before
  # the tide plugin itself.
  xdg.configFile."fish/conf.d/00-tide-config.fish".source = ./config/tide.fish;
  xdg.configFile."fish/conf.d/01-mono-smoke.fish".source = ./config/mono-smoke.fish;

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
      # Commands
      "c" = "clear";
      "ls" = "eza";

      # Programs
      "oc" = "opencode";
      "n" = "nvim";
      "terraform" = "tofu";
      "tf" = "tofu";
      "lg" = "lazygit";

      # Docker
      "dc" = "docker compose";
      "up" = "docker compose up";
      "stop" = "docker compose stop";
      "down" = "docker compose down";

      # Git
      "s" = "git status";
      "gs" = "git status";
      "a" = "git add";
      "gc" = "git commit -m";
      "gca" = "git commit -amend";
      "gp" = "git push";
      "gl" = "git log";
      "gcob" = "git checkout -b";
    };
  };
}
