{
    description = "Jacob's multi-platform configuration (macOS and Linux)";

    # Flake inputs
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/release-25.11"; # Unstable Nixpkgs

        # Home Manager
        home-manager.url = "github:nix-community/home-manager/release-25.11";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        # nix will normally use the nixpkgs defined in home-managers inputs, we only want one copy of nixpkgs though

        # Nix-Darwin
        darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
        darwin.inputs.nixpkgs.follows = "nixpkgs";

        # Nix-Homebrew
        nix-homebrew.url = "github:zhaofengli/nix-homebrew";

        # Sprite CLI
        sprite-cli.url = "github:jamiebrynes7/sprite-cli-nix";
        sprite-cli.inputs.nixpkgs.follows = "nixpkgs";
    };


    # Flake outputs
    outputs = { self, nixpkgs, home-manager, darwin, nix-homebrew, sprite-cli }:
    let
        repoDir = builtins.getEnv "REPO_DIR";
        mkDarwinSystem = { separateAdminAccount ? false }: darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
                home-manager.darwinModules.home-manager
                nix-homebrew.darwinModules.nix-homebrew
                {
                    nixpkgs.overlays = [ sprite-cli.overlays.default ];
                }
                ./hosts/macbook/default.nix
            ];
            specialArgs = {
                inherit repoDir separateAdminAccount;
            };
        };
        linuxPkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ sprite-cli.overlays.default ];
        };
        mkLinuxHome = { username, homeDirectory, enableSprite ? false }: home-manager.lib.homeManagerConfiguration {
            pkgs = linuxPkgs;
            modules = [
                ({ ... }: {
                    home = {
                        inherit username homeDirectory;
                    };
                })
                ./hosts/linux/home.nix
            ];
            extraSpecialArgs = {
                inherit repoDir username homeDirectory enableSprite;
            };
        };
    in {
        # macOS system configuration (run from admin account)
        darwinConfigurations.macbook = mkDarwinSystem { };

        # macOS system configuration (run from separate admin account)
        darwinConfigurations.macbook-admin = mkDarwinSystem { separateAdminAccount = true; };

        # Linux home-manager standalone configuration
        homeConfigurations.linux = mkLinuxHome {
            username = "jacob";
            homeDirectory = "/home/jacob";
        };

        homeConfigurations.sprite = mkLinuxHome {
            username = "sprite";
            homeDirectory = "/home/sprite";
            enableSprite = true;
        };
    };
}
