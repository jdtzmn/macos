{ lib, pkgs, ... }:
{
  home.activation.installGhEnhance = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # TODO(jacob): Move gh-enhance to shared/dev-packages.nix once it lands in
    # the flake-pinned nixpkgs channel (release-25.11 at time of writing).
    if ! ${pkgs.gh}/bin/gh extension list | ${pkgs.gnugrep}/bin/grep -q 'gh-enhance'; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/env PATH="/usr/bin:$PATH" ${pkgs.gh}/bin/gh extension install dlvhdr/gh-enhance || true
    fi
  '';
}
