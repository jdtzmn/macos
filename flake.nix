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

        # Nixpkgs unstable (used to source ruby_4_0 for nix-homebrew)
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

        # Sprite CLI
        sprite-cli.url = "github:jamiebrynes7/sprite-cli-nix";
        sprite-cli.inputs.nixpkgs.follows = "nixpkgs";
    };


    # Flake outputs
    outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, darwin, nix-homebrew, sprite-cli }:
    let
        repoDir = builtins.getEnv "REPO_DIR";
        unstablePkgsDarwin = import nixpkgs-unstable { system = "aarch64-darwin"; };
        mkDarwinSystem = { separateAdminAccount ? false }: darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
                home-manager.darwinModules.home-manager
                nix-homebrew.darwinModules.nix-homebrew
                {
                    nixpkgs.overlays = [
                        sprite-cli.overlays.default
                        # nix-homebrew 2026-05+ requires ruby_4_0, not in nixpkgs 25.11
                        (final: prev: { ruby_4_0 = unstablePkgsDarwin.ruby_4_0; })
                        # pi-coding-agent not yet in nixpkgs 25.11
                        (final: prev: { pi-coding-agent = unstablePkgsDarwin.pi-coding-agent; })
                    ];
                }
                ./hosts/macbook/default.nix
            ];
            specialArgs = {
                inherit repoDir separateAdminAccount;
            };
        };
        unstablePkgsLinux = import nixpkgs-unstable { system = "x86_64-linux"; };
        linuxPkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [
                sprite-cli.overlays.default
                # pi-coding-agent not yet in nixpkgs 25.11
                (final: prev: { pi-coding-agent = unstablePkgsLinux.pi-coding-agent; })
            ];
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

        # devpod dotfiles target: resolves user, home, and architecture at
        # evaluation time (rather than hardcoding "jacob"/"x86_64-linux" like
        # the targets above) so it works inside any devpod workspace,
        # regardless of container user or host CPU architecture (e.g. the
        # arm64 containers OrbStack runs natively on Apple Silicon). Evaluated
        # by setup.sh, running inside the container itself, so these reflect
        # that container's real user/arch, not the machine driving `nix eval`.
        devpodSystem = builtins.currentSystem;
        unstablePkgsDevpod = import nixpkgs-unstable { system = devpodSystem; };
        devpodPkgs = import nixpkgs {
            system = devpodSystem;
            overlays = [
                sprite-cli.overlays.default
                # pi-coding-agent not yet in nixpkgs 25.11
                (final: prev: { pi-coding-agent = unstablePkgsDevpod.pi-coding-agent; })
            ];
        };
        devpodUsername = builtins.getEnv "USER";
        devpodHomeDirectory = builtins.getEnv "HOME";
        mkDevpodHome = home-manager.lib.homeManagerConfiguration {
            pkgs = devpodPkgs;
            modules = [
                ({ ... }: {
                    home = {
                        username = devpodUsername;
                        homeDirectory = devpodHomeDirectory;
                    };
                })
                ./hosts/linux/home.nix
            ];
            extraSpecialArgs = {
                inherit repoDir;
                username = devpodUsername;
                homeDirectory = devpodHomeDirectory;
                enableSprite = false;
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

        # Generic target for devpod workspaces (see shared/devpod.nix and
        # setup.sh) - adapts to whatever user/home/architecture the
        # container actually has.
        homeConfigurations.devpod = mkDevpodHome;
    };
}
