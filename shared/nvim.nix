{ config, repoDir, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # sudoedit only uses EDITOR when it resolves to an existing executable and
  # otherwise falls back to the system editor (nano on Debian). A bare "nvim"
  # is resolved through sudo's own lookup, which does not see ~/.nix-profile/bin,
  # so give sudoedit an absolute path instead.
  home.sessionVariables.SUDO_EDITOR = "${config.home.profileDirectory}/bin/nvim";

  # Create symlink to shared nvim config
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/nvim";
}
