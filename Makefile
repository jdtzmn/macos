.PHONY: help macbook macbook-admin linux

# Default target shows help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  macbook       - Switch to macOS configuration"
	@echo "  macbook-admin - Switch to macOS configuration as administrator"
	@echo "  linux         - Switch to Linux (home-manager) configuration"

.DEFAULT_GOAL := help

# macOS system configuration
macbook:
	REPO_DIR=$(CURDIR) sudo -E nix run nix-darwin -- switch --flake .#macbook --impure

# macOS system configuration from administrator account
macbook-admin:
	sudo cp -r $(CURDIR) /tmp/macos-config
	REPO_DIR=$(CURDIR) HOMEBREW_BUNDLE_CASK_SKIP="tailscale-app wezterm zoom nordvpn" sudo -E -H nix run nix-darwin -- switch --flake /tmp/macos-config#macbook-admin --impure
	sudo rm -rf /tmp/macos-config

# Linux home-manager standalone configuration
linux:
	REPO_DIR=$(CURDIR) nix run home-manager -- switch --flake .#linux --impure
