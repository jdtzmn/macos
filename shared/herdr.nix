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
  herdrBin = "${herdr.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/herdr";
in
{
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/herdr/config.toml";

  home.activation.installHerdrNavigator = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! ${herdrBin} plugin list --json | ${pkgs.jq}/bin/jq -e \
      --arg root "${navigator}" \
      '.result.plugins[]? | select(
        .plugin_id == "herdr-navigator"
        and (.. | strings | select(. == $root))
      )' >/dev/null; then
      ${herdrBin} plugin uninstall herdr-navigator 2>/dev/null || true
      ${herdrBin} plugin link ${navigator} --enabled
    fi
  '';
}
