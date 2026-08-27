# Updating Pi and Extension Pins

Pi and its extensions must be upgraded as one compatibility bundle. A newer extension can require Pi APIs that older VMs do not provide, while a newer Pi can expose changes that older extensions do not expect.

## Current installation routes

- `shared/dev-packages.nix` installs `pi-coding-agent` for Home Manager targets.
- `flake.nix` supplies `pi-coding-agent` from `nixpkgs-unstable` for macOS, Linux, and DevPod.
- `shared/config/pi/settings.json` declares Pi-managed npm and Git packages.
- `setup.sh` applies the generic `homeConfigurations.devpod` target inside DevPod workspaces.

## Upgrade procedure

1. Inspect `flake.nix`, `shared/dev-packages.nix`, `shared/pi.nix`, and `shared/config/pi/settings.json`.
2. Choose the target Pi version. Prefer the version already validated on the local machine unless there is a specific reason to stay on an older VM version.
3. Inspect every direct package's npm metadata, especially `peerDependencies`, and identify versions supporting the chosen Pi version. Do not assume the latest release is compatible.
4. Pin the Pi package consistently for macOS, Linux, and DevPod. Do not leave the Pi source floating independently from the extension bundle.
5. Pin every direct package in `settings.json` with an explicit npm version. Pin Git-based packages to a tag or immutable commit. Pin a transitive package such as `entities` only when the importer cannot otherwise be pinned and the installer resolves it as a shared dependency.
6. Update Pi and all extension pins in the same change. Record compatibility exceptions in the commit or this document.
7. Validate the affected targets:

   ```bash
   nix eval .#homeConfigurations.linux.activationPackage.drvPath --impure
   nix eval .#darwinConfigurations.macbook.system.drvPath --impure
   nix eval .#darwinConfigurations.macbook-admin.system.drvPath --impure
   nix eval .#homeConfigurations.devpod.activationPackage.drvPath --impure
   nix flake check --impure
   ```

8. Review `git diff` and `git status`; stage only the intended Pi changes. Commit the bundle and push when requested.
9. Apply the configuration in each VM. A remote VM may need a new shell or Pi process after applying the update, but do not restart it automatically.

## Compatibility rules

- A Pi version change and extension pin changes are inseparable.
- A package with a peer requirement such as `pi-coding-agent >= 0.84.0` cannot be used with Pi `0.80.3`.
- Pinning only the package named in the first error is insufficient; check all direct Pi packages for peer and API requirements.
- Keep the VM installation path declarative and repeatable rather than relying on manually installed global Pi versions.
