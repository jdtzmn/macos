.PHONY: default

# Switch to the macbook configuration
default:
	sudo -E nix run nix-darwin -- switch --flake .#macbook --impure
