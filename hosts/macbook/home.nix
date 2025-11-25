{ pkgs, repoDir ? null, ... }:
{
  imports = [
    ../../shared/dev-packages.nix
    ../../shared/git.nix
    ../../shared/fish.nix
    ../../shared/direnv.nix
    ../../shared/wezterm.nix
    ../../shared/zed.nix
    ../../shared/opencode.nix
    ../../shared/nvim.nix
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home = {
    stateVersion = "25.05"; # Nix Darwin README.md says 25.05
  };

  ##############################
  # macOS-specific Packages
  ##############################

  home.packages = with pkgs; [
    terminal-notifier
  ];

  ##############################
  # macOS-specific Git Configuration
  ##############################

  # Support for 1Password SSH Signing (macOS only)
  programs.git.signing = {
    signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  };
}
