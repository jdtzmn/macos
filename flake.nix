{
    description = "Jacob's multi-platform configuration (macOS and Linux)";

    # Flake inputs
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11"; # Unstable Nixpkgs

        # Home Manager
        home-manager.url = "github:nix-community/home-manager/release-25.11";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        # nix will normally use the nixpkgs defined in home-managers inputs, we only want one copy of nixpkgs though

        # Nix-Darwin
        darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
        darwin.inputs.nixpkgs.follows = "nixpkgs";

        # Nix-Homebrew
        nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    };


    # Flake outputs
    outputs = { self, nixpkgs, home-manager, darwin, nix-homebrew }:
    let
        repoDir = builtins.getEnv "REPO_DIR";
        mkDarwinSystem = { separateAdminAccount ? false }: darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
                home-manager.darwinModules.home-manager
                nix-homebrew.darwinModules.nix-homebrew
                ./hosts/macbook/default.nix
            ];
            specialArgs = {
                inherit repoDir separateAdminAccount;
            };
        };
    in {
        # macOS system configuration (run from admin account)
        darwinConfigurations.macbook = mkDarwinSystem { };

        # macOS system configuration (run from separate admin account)
        darwinConfigurations.macbook-admin = mkDarwinSystem { separateAdminAccount = true; };

        # Linux home-manager standalone configuration
        homeConfigurations.linux = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
                ./hosts/linux/home.nix
            ];
            extraSpecialArgs = {
                inherit repoDir;
            };
        };
    };
}
