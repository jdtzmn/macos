{ pkgs, home-manager, ... }: {
    # Disable nix because we're using Determinate Nix
    nix.enable = false;

    # Set state version
    system.stateVersion = "25.05";

    ##############################
    # Shell
    ##############################

    environment.shells = [ pkgs.fish ];

    ##############################
    # User
    ##############################

    users.users.jacob = {
        name = "jacob";
        home = "/Users/jacob";
    };

    system.primaryUser = "jacob";

    # Open fish at zsh start
    programs.zsh.interactiveShellInit = "exec fish";

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

    ##############################
    # Nix-Homebrew (installs homebrew)
    ##############################

    nix-homebrew = {
        # Install Homebrew under the default prefix
        enable = true;

        # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
        enableRosetta = true;

        # User owning the Homebrew prefix
        user = "jacob";
    };

    ##############################
    # Homebrew (installs dependencies)
    ##############################

    homebrew = {
        enable = true;
        casks = [
            # Productivity
            "karabiner-elements"
            "alfred"
            "alt-tab"

            # Writing
            "notion"

            # Browser
            "brave-browser"

            # Music
            "spotify"

            # Programming
            "cursor"
            "zed"
            "wezterm"
            "tower"
            "tailscale-app"
            
            # Work
            "slack"
        ];
    };

    ##############################
    # Fonts
    ##############################

    fonts = {
        packages = [ pkgs.nerd-fonts.fira-code ];
    };

    ##############################
    # Install Rosetta 2 for Done.fish plugin.
    ##############################

    system.activationScripts.extraActivation.text = ''
        softwareupdate --install-rosetta --agree-to-license
    '';
}