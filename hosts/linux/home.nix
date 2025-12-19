{ repoDir ? null, ... }:
{
    imports = [
        ../../shared/dev-packages.nix
        ../../shared/git.nix
        ../../shared/fish.nix
        ../../shared/direnv.nix
        ../../shared/wezterm.nix
        ../../shared/zed.nix
        ../../shared/opencode.nix
        ../../shared/nvim.nix
    ];

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home = {
        username = "jacob";
        homeDirectory = "/home/jacob";
        stateVersion = "25.11";
    };

    ##############################
    # Linux-specific Git Configuration
    ##############################

    # Enable bash to launch fish interactively
    programs.bash = {
        enable = true;
        bashrcExtra = ''
            # Launch fish for interactive shells
            if [ -n "$PS1" ]; then
              if command -v fish &> /dev/null; then
                exec fish
              fi
            fi
        '';
    };
    programs.zsh.enable = false;
}
