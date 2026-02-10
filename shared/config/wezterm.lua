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

local function blend_toward_bg(fg, bg, t)
    local fh, fs, fl, _ = wezterm.color.parse(fg):hsla()
    local bh, bs, bl, _ = wezterm.color.parse(bg):hsla()
    local h = fh + (bh - fh) * t
    local s = fs + (bs - fs) * t
    local l = fl + (bl - fl) * t
    return wezterm.color.from_hsla(h, s, l, 1.0)
end

local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
local bg = scheme['background']
local dim = scheme.ansi[8]
local branch_inactive = blend_toward_bg(dim, bg, 0.35)
local highlight = scheme.ansi[4]
local tbg = set_alpha(bg, 0.8)
local opencode_status_colors = {
    complete_unseen = scheme.ansi[3],
    complete_seen = scheme.ansi[3],
    in_progress = scheme.ansi[4],
    waiting = scheme.ansi[2],
}

local opencode_complete_seen_by_tab = {}
local opencode_last_status_by_tab = {}

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

local function tab_cwd(tab)
    local pane = tab.active_pane
    if not pane then
        return nil
    end

    local cwd = pane.current_working_dir
    if not cwd then
        return nil
    end

    if type(cwd) == 'table' and cwd.file_path then
        return cwd.file_path
    end

    local value = tostring(cwd)
    local path = value:match('^file://[^/]*(/.*)$')
    if path then
        return (path:gsub('%%(%x%x)', function(hex)
            return string.char(tonumber(hex, 16))
        end))
    end

    return value
end

local function path_join(base, name)
    if base:sub(-1) == '/' then
        return base .. name
    end

    return base .. '/' .. name
end

local function dirname(path)
    if not path or path == '' then
        return nil
    end

    local parent = path:match('^(.*)/[^/]+$')
    if parent and parent ~= '' then
        return parent
    end

    if path:sub(1, 1) == '/' then
        return '/'
    end

    return nil
end

local function read_first_line(path)
    local file = io.open(path, 'r')
    if not file then
        return nil
    end

    local line = file:read('*l')
    file:close()
    return line
end

local function resolve_git_dir(start_dir)
    local dir = start_dir

    while dir do
        local dotgit = path_join(dir, '.git')
        local head = read_first_line(path_join(dotgit, 'HEAD'))
        if head then
            return dotgit
        end

        local dotgit_file = read_first_line(dotgit)
        if dotgit_file then
            local gitdir = dotgit_file:match('^gitdir:%s*(.+)%s*$')
            if gitdir and gitdir ~= '' then
                if gitdir:sub(1, 1) ~= '/' then
                    gitdir = path_join(dir, gitdir)
                end
                return gitdir
            end
        end

        if dir == '/' then
            break
        end

        local parent = dirname(dir)
        if not parent or parent == dir then
            break
        end
        dir = parent
    end

    return nil
end

local function read_git_branch(git_dir)
    local head = read_first_line(path_join(git_dir, 'HEAD'))
    if not head then
        return nil
    end

    local branch = head:match('^ref:%s+refs/heads/(.+)$')
    if branch and branch ~= '' then
        return branch
    end

    return nil
end

local branch_cache = {}

local function tab_git_branch(tab)
    local cwd = tab_cwd(tab)
    if not cwd or cwd == '' then
        return nil
    end

    local now = os.time()
    local cached = branch_cache[cwd]
    if cached and cached.expires >= now then
        return cached.value ~= false and cached.value or nil
    end

    local branch = nil
    local git_dir = resolve_git_dir(cwd)
    if git_dir then
        branch = read_git_branch(git_dir)
    end

    branch_cache[cwd] = {
        value = branch or false,
        expires = now + 2,
    }

    return branch
end

local function truncate_text(text, max_len)
    if #text <= max_len then
        return text
    end

    return text:sub(1, max_len - 3) .. '...'
end

local function tab_opencode_status(tab)
    local pane = tab.active_pane
    if not pane or type(pane.user_vars) ~= 'table' then
        return nil
    end

    local status = pane.user_vars.opencode_status
    if status == 'complete' or status == 'in_progress' or status == 'waiting' then
        return status
    end

    return nil
end

local function tab_opencode_display_status(tab)
    local status = tab_opencode_status(tab)
    if not status then
        return nil
    end

    local tab_id = tab.tab_id
    if not tab_id then
        return status
    end

    local previous_status = opencode_last_status_by_tab[tab_id]
    if status ~= previous_status then
        if status == 'complete' then
            opencode_complete_seen_by_tab[tab_id] = tab.is_active
        elseif status == 'in_progress' then
            opencode_complete_seen_by_tab[tab_id] = false
        end

        opencode_last_status_by_tab[tab_id] = status
    end

    if status == 'complete' then
        if tab.is_active then
            opencode_complete_seen_by_tab[tab_id] = true
        end

        if opencode_complete_seen_by_tab[tab_id] then
            return 'complete_seen'
        end

        return 'complete_unseen'
    end

    return status
end

-- Format the tab title
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local title = tostring(tab.tab_index + 1)
    local status = tab_opencode_display_status(tab)
    local title_text = ' ' .. title

    local cells = {
        { Background = { Color = "none" } },
    }

    if status then
        local icon = '● '
        if status == 'waiting' then
            icon = '🔔 '
        elseif status == 'complete_seen' then
            icon = '○ '
        end

        table.insert(cells, { Foreground = { Color = opencode_status_colors[status] } })
        table.insert(cells, { Text = ' ' .. icon })
        title_text = title
    end

    table.insert(cells, { Foreground = { Color = tab.is_active and highlight or dim } })
    table.insert(cells, { Text = title_text })

    local branch = tab_git_branch(tab)
    if branch then
        branch = truncate_text(branch, 28)
        table.insert(cells, { Foreground = { Color = tab.is_active and dim or branch_inactive } })
        table.insert(cells, { Text = '  ' .. branch })
    end

    return cells
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
