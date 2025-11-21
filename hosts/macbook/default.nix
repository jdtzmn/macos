{ pkgs, ... }: {
    # Disable nix because we're using Determinate Nix
    nix.enable = false;

    # Set state version
    system.stateVersion = "25.05";

    ##############################
    # Shell
    ##############################

    environment.shells = [ pkgs.fish ];

    # Yes, you do need to enable fish in nix-darwin and home-manager.. sigh
    programs.fish.enable = true;

    ##############################
    # User
    ##############################

    users.users.jacob = {
        name = "jacob";
        home = "/Users/jacob";
        shell = pkgs.fish;
        ignoreShellProgramCheck = true;
    };

    system.primaryUser = "jacob";

    ##############################
    # System Defaults
    ##############################

    # Dock
    system.defaults.dock.autohide = true;

    # Desktop
    # Disable standard click to show desktop
    system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;

    # Windows
    # Disable window margins (set window resize increments to 0)
    system.defaults.WindowManager.EnableTiledWindowMargins = false;

    # Disable cmd + space for Spotlight (requires restart)
    system.defaults.CustomUserPreferences = {
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # 64 is the configuration entry for Spotlight search
            "64" = {
                enabled = false;
            };
          };
        };
        # Figure out a way to disable ctrl+space for "Select the previous input source" so that Zed can show completions
    };

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
        taps = [
            "oven-sh/bun"
        ];
        brews = [
            # Programming
            "opencode"
            "asdf"
            "temporal"
            "uv"
            "bun"
            "dagger/tap/dagger"
        ];
        casks = [
            # Productivity
            "bettertouchtool"
            "alfred"
            "alt-tab"
            "homerow"
            "nordvpn"
            "zoom"
            "betterdisplay"
            "linear-linear"

            # AI Tools
            # Manually install Chorus

            # Writing
            "notion"

            # Browser
            "brave-browser"

            # Music
            "spotify"

            # Programming
            "cursor"
            "visual-studio-code"
            "zed"
            "wezterm"
            "tower"
            "tailscale-app"
            "orbstack"
            "conductor"
            "bruno"
            "dbeaver-community"

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
