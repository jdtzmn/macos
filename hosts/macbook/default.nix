{
  pkgs,
  repoDir ? null,
  separateAdminAccount ? false,
  ...
}:
{
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
  home-manager.extraSpecialArgs = {
    inherit repoDir;
  };
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
    autoMigrate = true;
  };

  ##############################
  # Homebrew (installs dependencies)
  ##############################

  homebrew = {
    enable = true;
    # When running from a separate admin account, install casks to user's Applications folder
    caskArgs.appdir =
      if separateAdminAccount then "/Users/jacob/Applications" else "/Applications";
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
      "betterdisplay"
      "linear-linear"

      # Design
      "kap"
      "figma"

      # AI Tools
      # Manually install Chorus
      "jan"

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
      "tower"
      "orbstack"
      "conductor"
      "bruno"
      "dbeaver-community"

      # Work
      "slack"
    ] ++ (if !separateAdminAccount then [
      # These casks require sudo during install
      "tailscale-app"
      "wezterm"
      "zoom"
      "nordvpn"
    ] else []);
  };

  ##############################
  # Fonts
  ##############################

  fonts = {
    packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  };

  ##############################
  # Install Rosetta 2 for Done.fish plugin.
  ##############################

  system.activationScripts.extraActivation.text = ''
    softwareupdate --install-rosetta --agree-to-license
  '';
}
