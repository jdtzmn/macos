{ config, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Create symlink to shared nvim config
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink (toString ./nvim);
}
