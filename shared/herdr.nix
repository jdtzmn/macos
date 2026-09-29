{ config, lib, pkgs, repoDir, herdr, ... }:
let
  navigator = pkgs.rustPlatform.buildRustPackage {
    pname = "herdr-navigator";
    version = "0.3.6";
    src = pkgs.fetchFromGitHub {
      owner = "thanhdat77";
      repo = "herdr-navigator";
      rev = "e12a97c5d9ddcd76ba18c985909ffeb4827afa6a";
      hash = "sha256-+xtBu4m2YenFH+W3Sv7atDvcsgChS5mKXgVgKomM768=";
    };
    cargoHash = "sha256-1fvQ8hyarP1WQwqIRvqKCkttwAMj3wGieue91/VNll8=";
    # Upstream's Nix-sandboxed test suite fails in v0.3.6; Herdr itself builds this plugin without tests.
    doCheck = false;
    installPhase = ''
      binary=$(find "$NIX_BUILD_TOP" -type f -path '*/release/herdr-navigator' -perm -u+x -print -quit)
      install -Dm755 "$binary" $out/target/release/herdr-navigator
      install -Dm644 herdr-plugin.toml $out/herdr-plugin.toml
    '';
  };
  agentProgress = pkgs.rustPlatform.buildRustPackage {
    pname = "herdr-agent-progress";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "jdtzmn";
      repo = "herdr-agent-progress";
      rev = "cef10ff983195c5210885e6b1104a32463e2f6b4";
      hash = "sha256-2h3bSvS7wYJZIQ1pxhb469F6yPcjmWoRykrzXObuU1M=";
    };
    cargoHash = "sha256-l8NGsp2J0ZdHwSKoXAhRBW9Ciw/QBZXt8j+0w1Bi/qU=";
    # One upstream test uses a host shell fixture unavailable in Nix's sandbox; the release build compiles successfully.
    doCheck = false;
    installPhase = ''
      binary=$(find "$NIX_BUILD_TOP" -type f -path '*/release/herdr-progress' -perm -u+x -print -quit)
      install -Dm755 "$binary" $out/target/release/herdr-progress
      install -Dm644 herdr-plugin.toml $out/herdr-plugin.toml
    '';
  };
  herdrPlugins = [
    { id = "herdr-navigator"; package = navigator; }
    { id = "agent-progress"; package = agentProgress; }
  ];
  herdrBin = "${herdr.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/herdr";
  agentProgressConfigDir = "${config.xdg.configHome}/herdr/plugins/config/agent-progress";
in
{
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/herdr/config.toml";

  home.file.".config/herdr/plugins/config/agent-progress/herdr-progress" = {
    text = ''
      #!/bin/sh
      export HERDR_PLUGIN_CONFIG_DIR='${agentProgressConfigDir}'
      export HERDR_PLUGIN_STATE_DIR='${config.xdg.stateHome}/herdr/plugins/agent-progress'
      exec '${agentProgress}/target/release/herdr-progress' "$@"
    '';
    executable = true;
  };
  home.file.".config/herdr/plugins/config/agent-progress/enabled".text = builtins.toJSON {
    registry = "${config.xdg.configHome}/herdr/plugins.json";
    root = agentProgress;
  };

  home.activation.installHerdrPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for plugin in ${lib.concatStringsSep " " (map (plugin: "${plugin.id}:${plugin.package}") herdrPlugins)}; do
      id="''${plugin%%:*}"
      root="''${plugin#*:}"
      if ! ${herdrBin} plugin list --json | ${pkgs.jq}/bin/jq -e \
        --arg id "$id" \
        --arg root "$root" \
        '.result.plugins[]? | select(
          .plugin_id == $id
          and (.. | strings | select(. == $root))
        )' >/dev/null; then
        ${herdrBin} plugin uninstall "$id" 2>/dev/null || true
        ${herdrBin} plugin link "$root" --enabled
      fi
    done
  '';
}
