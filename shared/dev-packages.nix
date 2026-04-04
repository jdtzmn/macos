{ lib, pkgs, ... }:
{
  home.packages = with pkgs;
    [
      docker
      docker-compose
      atlas
      sprite
      gh
      gh-dash
      gnumake
      ripgrep
      lazygit
      eza
      opentofu
      awscli2
      # Nix language servers
      nil
      nixd
    ]
    # Prefer newer Homebrew releases on macOS, but keep Linux/Sprite complete.
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      bun
      opencode
    ];
}
