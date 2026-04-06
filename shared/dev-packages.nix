{ lib, pkgs, enableSprite ? false, ... }:
{
  home.packages = with pkgs;
    [
      docker
      docker-compose
      atlas
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
    ++ lib.optionals enableSprite [
      sprite
    ]
    # Prefer newer Homebrew releases on macOS, but keep Linux/Sprite complete.
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      bun
      opencode
    ];
}
