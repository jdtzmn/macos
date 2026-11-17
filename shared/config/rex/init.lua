-- Splits (cmd+d, shift+cmd+d) and pane focus (alt+cmd+arrows) are Rex defaults.
rex.bind("shift+cmd+r", "client.tab.rename")

-- Vim-style pane focus, carried over from wezterm.lua
rex.bind("alt+h", "pane.focus", { direction = "left" })
rex.bind("alt+j", "pane.focus", { direction = "down" })
rex.bind("alt+k", "pane.focus", { direction = "up" })
rex.bind("alt+l", "pane.focus", { direction = "right" })
