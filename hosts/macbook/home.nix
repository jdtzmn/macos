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
        gh
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
        shellInit = ''
          source ${./config/config.fish}
        '';
        plugins = [
            {
                name = "done";
                src = pkgs.fishPlugins.done.src;
            }
        ];
        shellAbbrs = {
            "dc" = "docker compose";
            "oc" = "opencode";
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

    # Zed Editor
    programs.zed-editor = {
        enable = true;
        extensions = [

        ];
        userSettings = {
            agent = {
                inline_assistant_model = {
                    provider = "anthropic";
                    model = "claude-sonnet-4-5-latest";
                };
                default_profile = "minimal";
                default_model = {
                    provider = "anthropic";
                    model = "claude-sonnet-4-5-latest";
                };
                model_parameters = [ ];
            };
            agent_servers = {
                OpenCode = {
                    command = "opencode";
                    args = [ "acp" ];
                    env = { };
                };
            };
            vim_mode = true;
            relative_line_numbers = true;
            telemetry = {
                diagnostics = false;
                metrics = false;
            };
            ui_font_size = 16;
            buffer_font_size = 12;
            theme = {
                mode = "dark";
                light = "Tokyo Night Light";
                dark = "Tokyo Night";
            };
            file_scan_inclusions = [
                ".env"
                ".env*"
            ];
        };
        userKeymaps = [
            {
                context = "Editor && vim_mode == insert";
                bindings = {
                "j k" = "vim::NormalBefore";
                };
            }
        ];
    };


    # Opencode
    # When supported in the future by home-manager,
    # remove package above and configuration below
    # programs.opencode = {
    #     enable = true;
    # };
    home.file.".config/opencode/opencode.jsonc".source = ./config/opencode/opencode.jsonc;
    home.file.".config/opencode/plugin/notification.js".source = ./config/opencode/plugin/notification.js;
}
