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

## Running as a separate Administrator

If you have a separate admin account, use the following trick to install to
the `jacob` user's home directory:

```bash
# From within the macos repository
su admin
sudo make macbook-admin
```

Some packages can't be installed with homebrew this way, so you may need to install them manually or use a different method.

## Claude Code installation

Claude Code is installed through Bun by `shared/npm-cli-packages.nix` on both
macOS and Linux. Bun can block dependency postinstall scripts, leaving Claude's
launcher installed without its native binary. Every Home Manager activation
explicitly runs Claude's supported `install.cjs` with Nix-managed Node after the
Bun install, then verifies the exact `~/.bun/bin/claude` launcher with `--version`.
This covers fresh installs, upgrades, and same-version reapplies without enabling
scripts for unrelated packages or switching to a different installer.

Apply the fix with the normal target for your host: `make macbook`,
`make macbook-admin`, or `make linux`. No separate manual postinstall is required.
If the platform-native optional dependency is missing, activation fails rather
than accepting a broken launcher; restore optional-dependency downloads and
reapply the target. The postinstall alone can report success in that situation,
so the launcher verification is required.

If your shell still reports the old error after applying, check which install
it resolves before changing anything:

```bash
command -v claude
~/.bun/bin/claude --version
```

The shared configuration adds `~/.bun/bin` to the session PATH. A different
`claude` earlier in PATH is a separate install, not the launcher verified during
activation.
