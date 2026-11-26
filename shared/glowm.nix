{ stdenvNoCC, fetchurl }:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "glowm";
  # To update, pick a release at https://github.com/atani/glowm/releases,
  # set version without the leading v, and copy each archive's SHA-256 from
  # that release's checksums.txt into the matching platform entry below.
  version = "0.4.0";

  src = let
    assets = {
      aarch64-darwin = { suffix = "darwin_arm64"; sha256 = "830b352e6fd87a3995f77c400ca12e8c6cea64761f053c598c3015fc4ab86038"; };
      x86_64-darwin = { suffix = "darwin_amd64"; sha256 = "cc87607f42ca6758ade26095603f90a385170c2baa7c11fbc0fc7b382267374d"; };
      aarch64-linux = { suffix = "linux_arm64"; sha256 = "fb1840ca94dfb5829ac75f48662ad8ce5904a19fb276dafd5423eecb87573cda"; };
      x86_64-linux = { suffix = "linux_amd64"; sha256 = "883f80e4fa5306b6a6c47431662a1fd80a54ea6d34ae7be8181c1e5aef99f458"; };
    };
    inherit (assets.${stdenvNoCC.hostPlatform.system}) suffix sha256;
    inherit (finalAttrs) version;
  in fetchurl {
    url = "https://github.com/atani/glowm/releases/download/v${version}/glowm_${version}_${suffix}.tar.gz";
    inherit sha256;
  };

  sourceRoot = ".";
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 glowm "$out/bin/glowm"
    runHook postInstall
  '';

  meta.mainProgram = "glowm";
})
