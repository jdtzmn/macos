# macOS Configuration

1. Install Determinate Nix
1. Create `.env` from `.env.example` and source it
1. Run the `nix-darwin` setup with `make`

```
$ make
```

> **Tip:** The `-E` flag for `sudo` and the `--impure` flag for `nix` preserves your environment variables (such as those loaded from `.env`), which is often necessary for secrets or configuration to be available during the `nix-darwin` switch.

