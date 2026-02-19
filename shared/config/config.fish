# Homebrew (macOS only)
if test (uname) = "Darwin"
    eval "$(/opt/homebrew/bin/brew shellenv)"
end

# Port shell hook
port shell-hook fish | source

set -l repo_env "$HOME/Documents/GitHub/macos/.env"
if test -f "$repo_env"
    set -l allowlisted_env_keys GITHUB_MCP_TOKEN
    while read -l line
        set line (string trim -- "$line")
        if test -z "$line"
            continue
        end
        if string match -qr '^#' -- "$line"
            continue
        end
        if not string match -qr '^[A-Za-z_][A-Za-z0-9_]*=' -- "$line"
            continue
        end

        set -l parts (string split -m 1 '=' -- "$line")
        set -l key $parts[1]
        if not contains -- "$key" $allowlisted_env_keys
            continue
        end

        set -l value (string trim -- "$parts[2]")
        if string match -qr '^".*"$' -- "$value"
            set value (string sub -s 2 -e -1 -- "$value")
        else if string match -qr "^'.*'\$" -- "$value"
            set value (string sub -s 2 -e -1 -- "$value")
        end

        set -gx $key "$value"
    end < "$repo_env"
end

# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

# GitHub alias function
function github
    if test -z "$argv"
        cd ~/Documents/GitHub
    else
        cd ~/Documents/GitHub/$argv
    end
end

# Fish pure prompt
# https://pure-fish.github.io/pure/#slowness-try-async-git-prompt
set -g async_prompt_functions _pure_prompt_git
set -g pure_enable_single_line_prompt true
set -g pure_color_mute brcyan

# Add bun global binaries to path
fish_add_path -g "$HOME/.bun/bin"
