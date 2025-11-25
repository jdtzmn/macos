local options = {
  transparent = vim.g.transparent_enabled,
  styles = {
    sidebars = "transparent",
    floats = "transparent",
  }
}

require('tokyonight').setup(options) 
