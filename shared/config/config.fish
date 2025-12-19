# Homebrew (macOS only)
if test (uname) = "Darwin"
    eval "$(/opt/homebrew/bin/brew shellenv)"
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
