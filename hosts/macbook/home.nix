{ ... }: {
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home = {
        stateVersion = "25.05"; # Nix Darwin README.md says 25.05
    };

    ##############################
    # Programs
    ##############################

    # Enable fish
    programs.fish.enable = true;

    # Wezterm

    # Git
    programs.git = {
        enable = true;
        userName = "Jacob Daitzman";
        userEmail = "jdtzmn@gmail.com";
    };
}