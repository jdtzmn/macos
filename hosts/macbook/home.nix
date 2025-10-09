{ pkgs, ... }:
let
    gitSigningKey = builtins.getEnv "GIT_SIGNING_KEY";
in {
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home = {
        stateVersion = "25.05"; # Nix Darwin README.md says 25.05
    };

    ##############################
    # Packages
    ##############################

    home.packages = with pkgs; [
        terminal-notifier
        docker
        docker-compose
        bun
    ];

    ##############################
    # Programs
    ##############################

    # Enable fish
    programs.fish = {
        enable = true;
        interactiveShellInit = ''
            set fish_greeting # Disable greeting
        '';
        plugins = [
            {
                name = "done";
                src = pkgs.fishPlugins.done.src;
            }
        ];
        shellAliases = {
            "dc" = "docker compose";
        };
    };

    # Wezterm
    home.file.".config/wezterm/wezterm.lua".source = ./config/wezterm.lua;

    # Git
    programs.git = {
        enable = true;
        userName = "Jacob Daitzman";
        userEmail = "jdtzmn@gmail.com";

        # Support for 1Password SSH Signing
        signing = {
            format = "ssh";
            signByDefault = true;
            key = gitSigningKey;
            signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };

        aliases = {
            s = "status";
        };
    };

    # Direnv
    programs.direnv = {
        enable = true;
    };

    # Opencode
    # When supported in the future by home-manager,
    # remove package above and configuration below
    # programs.opencode = {
    #     enable = true;
    # };
    home.file.".config/opencode/opencode.jsonc".source = ./config/opencode.jsonc;
}
