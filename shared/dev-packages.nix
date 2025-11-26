{ pkgs, ... }:
{
  home.packages = with pkgs; [
    docker
    docker-compose
    bun
    gh
    gnumake
    ripgrep
    # Nix language servers
    nil
    nixd
  ];
}
