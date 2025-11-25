.PHONY: help macbook linux

# Default target shows help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  macbook  - Switch to macOS configuration"
	@echo "  linux    - Switch to Linux (home-manager) configuration"

.DEFAULT_GOAL := help

# macOS system configuration
macbook:
	REPO_DIR=$(CURDIR) sudo -E nix run nix-darwin -- switch --flake .#macbook --impure

# Linux home-manager standalone configuration
linux:
	REPO_DIR=$(CURDIR) nix run home-manager -- switch --flake .#linux --impure
