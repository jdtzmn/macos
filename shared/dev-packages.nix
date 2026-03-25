{ pkgs, ... }:
{
  home.packages = with pkgs; [
    docker
    docker-compose
    bun
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
  ];
}
