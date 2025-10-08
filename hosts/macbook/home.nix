{ ... }: {
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home = {
        homeDirectory = "/Users/jacob";
        stateVersion = "25.05"; # Nix Darwin README.md says 25.05
    };
}