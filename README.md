# macOS Configuration

1. Install Determinate Nix
1. Create `.env` from `.env.example` and source it
1. Run the `nix-darwin` setup with `make macbook`

```
$ make macbook
```

> **Tip:** The `-E` flag for `sudo` and the `--impure` flag for `nix` preserves your environment variables (such as those loaded from `.env`), which is often necessary for secrets or configuration to be available during the `nix-darwin` switch.

1. Change the default shell to fish

```
$ chsh -s /run/current-system/sw/bin/fish
```

1. Configure BetterTouchTool and Alfred manuall (to be automatic in the future)
1. Make recommended security changes

## Octet configuration

Home Manager links `~/.octet` to `shared/config/octet/`. Only `config.toml`
is tracked; Octet's credentials, sessions, and other runtime files are ignored.
Before the first switch on a machine with an existing `~/.octet` directory,
close Octet and move the directory aside. After the switch, restore the runtime
files through the link without overwriting the repository's `config.toml`.

## Running as a separate Administrator

If you have a separate admin account, use the following trick to install to
the `jacob` user's home directory:

```bash
# From within the macos repository
su admin
sudo make macbook-admin
```

Some packages can't be installed with homebrew this way, so you may need to install them manually or use a different method.
