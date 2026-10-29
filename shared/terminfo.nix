{ pkgs, ... }:
let
  # Compiled with this platform's own ncurses so the directory layout (x/ on
  # Linux, hex directories like 78/ on macOS) matches what its readers expect.
  ghosttyTerminfo = pkgs.runCommand "ghostty-terminfo" { nativeBuildInputs = [ pkgs.ncurses ]; } ''
    mkdir -p $out
    tic -x -o $out ${./config/xterm-ghostty.terminfo}
  '';
in
{
  # Install into ~/.terminfo, the first place ncurses looks, so system tools
  # (nano, vim, less) and sudoedit know Ghostty's terminal type on machines
  # that only have the stock terminfo database, such as remote VMs. Linked
  # per file so any existing ~/.terminfo entries are left alone.
  home.file.".terminfo" = {
    source = ghosttyTerminfo;
    recursive = true;
  };
}
