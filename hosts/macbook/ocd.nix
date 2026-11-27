{ stdenvNoCC, fetchurl }:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ocd";
  version = "0.5.1";

  src = fetchurl {
    url = "https://github.com/sphinxid/ocd/releases/download/v${finalAttrs.version}/ocd-v${finalAttrs.version}-darwin-arm64.tar.gz";
    sha256 = "0209227b05743d4c6918e18ea31bf1ef96165f29064b63935527c833dc9a6441";
  };

  dontBuild = true;
  dontStrip = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 ocd "$out/bin/ocd"
    runHook postInstall
  '';

  meta = {
    mainProgram = "ocd";
    platforms = [ "aarch64-darwin" ];
  };
})
