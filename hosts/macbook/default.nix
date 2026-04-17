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
  system.stateVersion = "25.11";

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
        # 60 is "Select the previous input source" (Ctrl+Space)
        "60" = {
          enabled = false;
        };
        # 64 is the configuration entry for Spotlight search
        "64" = {
          enabled = false;
        };
      };
    };
    "com.apple.Siri" = {
      # Disable keyboard shortcut invocation for Siri (e.g. double-press Command)
      KeyboardShortcutSAE = {
        enabled = false;
      };
      # Keep the legacy Siri shortcut path disabled as well
      KeyboardShortcutPreSAE = {
        enabled = false;
      };
    };
  };

  ##############################
  # Home Manager
  ##############################

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit repoDir;
    enableSprite = true;
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
      "entireio/tap"
      "oven-sh/bun"
    ];
    brews = [
      # Prefer Homebrew for faster-moving CLI releases that lag in nixpkgs.
      # Programming
      "opencode"
      "asdf"
      "temporal"
      "uv"
      "bun"
      "dagger/tap/dagger"
      "beads"
 
      # CLI File Explorer
      "yazi"
      "fd" # File Searching
      "poppler" # PDF preview
      "jq" # JSON preview
      "ffmpeg" # Video thumbnails
      "resvg" # SVG preview
    ];
    casks = [
      # Productivity
      "bettertouchtool"
      "alfred"
      "raycast"
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
      "1password-cli"
      "tower"
      "orbstack"
      "conductor"
      "bruno"
      "dbeaver-community"

      # Work
      "slack"
      "entireio/tap/entire"
    ] ++ (if !separateAdminAccount then [
      # These casks require sudo during install
      "tailscale-app"
      "wezterm@nightly"
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
