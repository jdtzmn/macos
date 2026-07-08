#!/usr/bin/env bash
# devpod dotfiles install script (see:
# https://devpod.sh/docs/developing-in-workspaces/dotfiles-in-a-workspace).
#
# devpod runs this automatically in any workspace once
# `devpod context set-options -o DOTFILES_URL=... -o DOTFILES_SCRIPT=setup.sh`
# has been set (shared/devpod.nix does this on every home-manager switch).
# It installs Nix and applies this repo's `homeConfigurations.devpod`
# home-manager configuration (fish, git, nvim, tmux, opencode, etc.),
# regardless of which project the workspace was opened for.
#
# Nix is installed single-user (no daemon) here rather than multi-user:
# devcontainers/devpod workspaces have no init system to run `nix-daemon`
# as a persistent service, which a multi-user install requires.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v nix >/dev/null 2>&1; then
	if [ ! -d /nix ]; then
		if command -v sudo >/dev/null 2>&1; then
			sudo mkdir -m 0755 -p /nix
			sudo chown "$(id -u):$(id -g)" /nix
		else
			mkdir -m 0755 -p /nix
		fi
	fi

	tmp_installer="$(mktemp)"
	curl -sSL https://nixos.org/nix/install -o "$tmp_installer"
	sh "$tmp_installer" --no-daemon --yes
	rm -f "$tmp_installer"
fi

# Layout-agnostic: the classic nixos.org single-user installer (used above
# when Nix isn't already present) ships nix.sh under ~/.nix-profile, but
# some workspaces already have Nix installed via the Determinate installer
# before this script runs (e.g. via postCreate.sh), which instead installs
# a system-wide hook at /etc/profile.d/nix.sh and leaves ~/.nix-profile as
# a plain (non-nix-containing) user profile. Try both.
# shellcheck disable=SC1091
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
	source "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -f /etc/profile.d/nix.sh ]; then
	source /etc/profile.d/nix.sh
fi

mkdir -p "$HOME/.config/nix"
if ! grep -q "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
	echo "experimental-features = nix-command flakes" >>"$HOME/.config/nix/nix.conf"
fi

REPO_DIR="$SCRIPT_DIR" nix run home-manager -- switch -b backup --flake "${SCRIPT_DIR}#devpod" --impure
