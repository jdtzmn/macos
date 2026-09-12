{ lib, pkgs, ... }:
{
  # Node runtime and NPM-distributed command-line tools.
  home.packages = with pkgs;
    [
      nodejs
      pi-coding-agent
    ]
    # Prefer newer Homebrew releases on macOS, but keep Linux/Sprite complete.
    ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      bun
      opencode
    ];
}
