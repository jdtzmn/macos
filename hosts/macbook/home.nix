{ pkgs, ... }:
{
  imports = [
    ../../shared/index.nix
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home = {
    stateVersion = "25.11"; # Nix Darwin README.md says 25.11
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
