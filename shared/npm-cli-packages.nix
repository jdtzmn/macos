{ config, lib, pkgs, ... }:
let
  globalNpmPackages = [
    "@earendil-works/pi-coding-agent"
    "opencode-ai"
    "@jdtzmn/port"
  ];
  globalNpmPackageArgs =
    lib.concatMapStringsSep " " (package: lib.escapeShellArg "${package}@latest") globalNpmPackages;
  # Use Bun's default locations so `bun pm ls -g` and PATH resolve the same CLIs.
  bunGlobalDir = "${config.home.homeDirectory}/.bun/install/global";
  bunGlobalBinDir = "${config.home.homeDirectory}/.bun/bin";
in
{
  # Keep Node available for globally installed CLIs with a Node shebang.
  home.packages = [ pkgs.nodejs ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [ pkgs.bun ];

  # Bun's Nix package runs the activation command; installed CLIs live outside
  # the Nix store so every activation can resolve their current npm releases.
  home.sessionPath = [ bunGlobalBinDir ];
  home.activation.installGlobalNpmPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export BUN_INSTALL_GLOBAL_DIR=${lib.escapeShellArg bunGlobalDir}
    export BUN_INSTALL_BIN=${lib.escapeShellArg bunGlobalBinDir}
    run ${lib.getExe pkgs.bun} add --global --force ${globalNpmPackageArgs}
  '';
}
