{
    description = "Jacob's multi-platform configuration (macOS and Linux)";

    # Flake inputs
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # Unstable Nixpkgs

        # Home Manager
        home-manager.url = "github:nix-community/home-manager/master";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        # nix will normally use the nixpkgs defined in home-managers inputs, we only want one copy of nixpkgs though

        # Nix-Darwin
        darwin.url = "github:nix-darwin/nix-darwin/master";
        darwin.inputs.nixpkgs.follows = "nixpkgs";

        # Nix-Homebrew
        nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    };


    # Flake outputs
    outputs = { self, nixpkgs, home-manager, darwin, nix-homebrew }: {
        # macOS system configuration
        darwinConfigurations.macbook = darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
                home-manager.darwinModules.home-manager
                nix-homebrew.darwinModules.nix-homebrew
                ./hosts/macbook/default.nix
            ];
        };

        # Linux home-manager standalone configuration
        homeConfigurations.linux = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
                ./hosts/linux/home.nix
            ];
        };
    };
}
