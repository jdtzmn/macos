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
config.window_decorations = "RESIZE|MACOS_FORCE_DISABLE_SHADOW"
config.window_padding = {
    left = 24,
    right = 24,
    top = 24,
    bottom = 24
}

-- Prepare colors for title and tab bar
local function set_alpha(c, a)
    local fh, fs, fl, _ = wezterm.color.parse(c):hsla()
    return wezterm.color.from_hsla(fh, fs, fl, a)
end

local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
local bg = scheme['background']
local dim = scheme.ansi[8]
local highlight = scheme.ansi[4]
local tbg = set_alpha(bg, 0.8)

-- Customize titlebar
config.window_frame = {
    active_titlebar_bg = tbg,
    font = wezterm.font('JetBrainsMono Nerd Font'),
    font_size = 12,
}

-- Customize tab bar
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.hide_tab_bar_if_only_one_tab = true

-- Customize tab bar colors
config.colors = {
    split = "none",
    tab_bar = {
        inactive_tab_edge = "none",
    },
}

-- Format the tab title
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local title = tab.tab_title
    if title and #title > 0 then
        title = tab.tab_title
    else
        title = tab.tab_index + 1
    end
    return {
        { Background = { Color = "none" } },
        { Foreground = { Color = tab.is_active and highlight or dim } },
        { Text = ' ' .. title .. '' },
    }
end)

-- Set window opacity based on the focused window
config.window_background_opacity = 0.8
config.macos_window_background_blur = 80

-- Pane navigation with Alt + hjkl
config.keys = {
  { key = 'h', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Right' },
}

-- Return the configuration to wezterm
return config
