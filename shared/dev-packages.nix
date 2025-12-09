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
    exa
    # Nix language servers
    nil
    nixd
  ];
}
