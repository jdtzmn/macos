{ config, repoDir, ... }:
{
  home.file.".pi/agent".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/shared/config/pi";

  # pi runs `npm install -g pi-web-access` on startup/first-use. nixpkgs'
  # `nodejs` (added in dev-packages.nix) has no writable global-install
  # prefix by default: npm's global prefix defaults to the nodejs package's
  # own Nix store path, which is always read-only ("dr-xr-xr-x", immutable
  # by Nix's design). That makes ANY `npm install -g` fail with EACCES, not
  # just this one package. Point npm's global prefix somewhere writable
  # instead, and make sure whatever npm installs there ends up on PATH.
  #
  # Note: Home Manager has no `programs.npm` module, so we manage `~/.npmrc`
  # directly instead.
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';
  home.sessionPath = [ "${config.home.homeDirectory}/.npm-global/bin" ];
}
