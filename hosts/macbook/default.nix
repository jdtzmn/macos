{ pkgs, home-manager, ... }: {
    # Disable nix because we're using Determinate Nix
    nix.enable = false;

    # Set state version
    system.stateVersion = "25.05";

    # Enable fish
    programs.fish.enable = true;

    ##############################
    # User
    ##############################

    users.users.jacob = {
        name = "jacob";
        home = "/Users/jacob";
    };

    system.primaryUser = "jacob";

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