{ lib, pkgs, herdr, enableSprite ? false, ... }:
{
  home.packages = with pkgs;
    [
      docker
      docker-compose
      atlas
      glow
      gh
      gh-dash
      gnumake
      fzf
      bat
      ripgrep
      herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
      delta
      lazygit
      eza
      opentofu
      awscli2
      kubectl
      croc
      mosh
      # Nix language servers
      nil
      nixd
    ]
    ++ lib.optionals enableSprite [
      sprite
    ]
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      # C/C++ toolchain (provides cc/c++/g++) so node-gyp can build native
      # modules like node-pty on VMs without a system compiler.
      gcc
    ];
}
