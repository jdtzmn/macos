{ lib, pkgs, enableSprite ? false, ... }:
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
      ripgrep
      delta
      lazygit
      eza
      opentofu
      awscli2
      kubectl
      pi-coding-agent
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
