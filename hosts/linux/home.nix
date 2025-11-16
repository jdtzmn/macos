{ pkgs, ... }:
let
    gitSigningKey = builtins.getEnv "GIT_SIGNING_KEY";
in {
    imports = [
        ../../shared/dev-packages.nix
        ../../shared/git.nix
        ../../shared/fish.nix
        ../../shared/direnv.nix
        ../../shared/wezterm.nix
        ../../shared/zed.nix
        ../../shared/opencode.nix
    ];

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home = {
        username = "jacob";
        homeDirectory = "/home/jacob";
        stateVersion = "25.05";
    };

    ##############################
    # Linux-specific Git Configuration
    ##############################

    # For Linux, use SSH key directly
    programs.git.signing = {
        format = "ssh";
        signByDefault = true;
    };

    # Disable other shells to ensure fish is default
    programs.bash.enable = false;
    programs.zsh.enable = false;
}
