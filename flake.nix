{
    description = "Jacob's macOS configuration";

    # Flake inputs
    inputs = {
        nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505.812676"; # Stable Nixpkgs

        # Home Manager
        home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.2505.4813";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        # nix will normally use the nixpkgs defined in home-managers inputs, we only want one copy of nixpkgs though

        # Nix-Darwin
        darwin.url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.2505.2190";
        darwin.inputs.nixpkgs.follows = "nixpkgs";

        # Nix-Homebrew
        nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    };
  


    # Flake outputs
    outputs = { self, nixpkgs, home-manager, darwin, nix-homebrew }: {
        darwinConfigurations.macbook = darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
                home-manager.darwinModules.home-manager
                nix-homebrew.darwinModules.nix-homebrew
                ./hosts/macbook/default.nix
            ];
        };
    };
}
