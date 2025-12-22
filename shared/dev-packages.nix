{ pkgs, ... }:
{
  home.packages = with pkgs; [
    docker
    docker-compose
    bun
    gh
    gnumake
    ripgrep
    nnn
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
