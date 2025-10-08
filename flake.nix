{
    description = "Jacob's macOS configuration";

    # Flake inputs
    inputs = {
        nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505.810859"; # Stable Nixpkgs
        home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.2505.4813"; # Home-Manager
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        # nix will normally use the nixpkgs defined in home-managers inputs, we only want one copy of nixpkgs though
        darwin.url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.2505.2190"; # Darwin
        darwin.inputs.nixpkgs.follows = "nixpkgs";
    };
  


    # Flake outputs
    outputs = { self, nixpkgs, home-manager, darwin }: {
        darwinConfigurations.macbook = darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
                home-manager.darwinModules.home-manager
                ./hosts/macbook/default.nix
            ];
        };
    };
}
