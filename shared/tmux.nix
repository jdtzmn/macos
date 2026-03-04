{ pkgs, repoDir, ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    extraConfig = "source-file ${repoDir}/shared/config/tmux.conf";
  };
}
