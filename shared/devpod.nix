{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.devpod ];

  # Point devpod's dotfiles support at this repo so every future `devpod up`
  # (for any project, not just this one) automatically installs Nix and
  # applies the `homeConfigurations.devpod` home-manager config via
  # `setup.sh`. See flake.nix and setup.sh for the other half of this.
  home.activation.setupDevpodDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v devpod &>/dev/null; then
      $DRY_RUN_CMD ${pkgs.devpod}/bin/devpod context set-options \
        -o DOTFILES_URL=https://github.com/jdtzmn/macos.git \
        -o DOTFILES_SCRIPT=setup.sh || true
    fi
  '';
}
