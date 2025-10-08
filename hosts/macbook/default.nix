{ pkgs, ... }: {
    # Make sure the nix daemon always runs
    services.nix-daemon.enable = true;
    # Installs a version of nix, that dosen't need "experimental-features = nix-command flakes" in /etc/nix/nix.conf
    services.nix-daemon.package = pkgs.nixFlakes;

    # Enable fish
    programs.fish.enable = true;

    ##############################
    # System Defaults
    ##############################

    # Dock
    system.defaults.dock.autohide = true;

    # Windows
    # Disable window margins (set window resize increments to 0)
    system.defaults.WindowManager.EnableTiledWindowMargins = false;

    ##############################
    # Home Manager
    ##############################
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.jacob = import ./home.nix;
}