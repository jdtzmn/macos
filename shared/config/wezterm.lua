-- Pull in the wezterm API
local wezterm = require 'wezterm'


-- This will hold the configuration.
local config = wezterm.config_builder()

-- Change the font
config.font = wezterm.font('JetBrainsMono Nerd Font')

-- Adjust default window size
config.initial_rows = 30
config.initial_cols = 100

-- Set color scheme
config.color_scheme = 'Tokyo Night'

-- Set top bar appearance to match Tokyo Night
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.window_decorations = "RESIZE"
config.window_padding = {
    left = 24,
    right = 24,
    top = 24,
    bottom = 24
}

config.window_frame = {
    active_titlebar_bg = '#1a1b26',
    inactive_titlebar_bg = '#16161e',
}

config.colors = {
    tab_bar = {
        background = '#16161e',
    },
}


-- Set window opacity based on the focused window

config.window_background_opacity = 0.8
config.macos_window_background_blur = 80

-- Return the configuration to wezterm
return config
