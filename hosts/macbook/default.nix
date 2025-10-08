{ pkgs, home-manager, ... }: {
    # Make sure the nix daemon always runs
    services.nix-daemon.enable = true;

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
    home-manager.users.jacob = {
        imports = [ ./home.nix ];
    };
}