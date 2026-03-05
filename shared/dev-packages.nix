{ pkgs, ... }:
{
  home.packages = with pkgs; [
    docker
    docker-compose
    bun
    sprite
    gh
    gnumake
    ripgrep
    lazygit
    eza
    opentofu
    awscli2
    gh
    # Nix language servers
    nil
    nixd
  ];
}
