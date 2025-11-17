{ config, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Create symlink to shared nvim config
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink ./nvim;
}
