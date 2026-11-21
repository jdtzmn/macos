# SSH into a new Linux machine with 1Password

Two scripts that bring up a Debian/Ubuntu box and let you reach it with a key
held in the 1Password SSH agent. The private key never leaves 1Password; the
remote only gets the public half.

| Script | Runs on | Does |
| --- | --- | --- |
| `setup` | the Linux machine | installs and enables `openssh-server`, prepares `~/.ssh`; `--harden` disables password login, root login and X11 forwarding; `--tailscale-only` firewalls SSH to Tailscale |
| `enroll` | your Mac | lists the 1Password agent's keys for you to pick from, installs its public key on the remote, adds a `Host` block to `~/.ssh/config`, verifies key login, then offers to harden the remote by running `setup --harden` over ssh |

Both are idempotent, so re-running them is safe.

## Prerequisites

- 1Password SSH agent enabled (Settings → Developer) and `Host *` in `~/.ssh/config` pointing `IdentityAgent` at it.
- The remote is reachable from the Mac (for example over Tailscale) and you know its password for the one-time key install.

## Steps

1. **Create the key.** In 1Password, make a new SSH key (ED25519) in the `Personal` vault, named after the machine (e.g. `Build Box SSH Key`). One key per machine keeps a compromise contained. If it is in another vault, enable that vault in `~/.config/1Password/ssh/agent.toml`.
2. **On the Linux machine**, get this script there (clone the repo, or `scp` it) and run:
   ```bash
   scripts/ssh/setup
   ```
3. **On the Mac**:
   ```bash
   scripts/ssh/enroll build-box 100.64.0.10 --user alice
   ```
   Run it bare and it offers the other online Linux and macOS machines on your tailnet as a numbered list (the pick supplies both the host and the alias), then asks for the username and which key to use from a numbered list (never guessed). `name` is the alias for `ssh build-box`. Use `--key "<text>"` to name the key by title and skip the picker. You are asked for the remote password once.
4. **Harden.** Once key login is verified, `enroll` asks `Disable password login on <host>? [Y/n]` and, on yes, runs `setup --harden` on the remote (you type the remote `sudo` password), then confirms key login still works and password login is rejected. `--harden` skips the question, `--no-harden` skips the offer. Add `--tailscale-only` to also firewall the remote so SSH is reachable only over Tailscale; do not use it if you reach that machine any other way.
5. **Check** `ssh build-box` works and prompts for Touch ID.

To harden a machine you enrolled earlier, run `enroll` again: it skips the key install and goes straight to the hardening offer. You can also run `scripts/ssh/setup --harden` on the machine directly.

## Troubleshooting

- **Your key is not in the picker**: it is not in the agent. Check the vault and `agent.toml`, then `SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ssh-add -l`.
- **`Too many authentication failures`**: the host entry needs `IdentitiesOnly yes` and an `IdentityFile` pointing at the `.pub`; `enroll` writes both.
- **Key login fails after install**: unlock 1Password, and check the remote has `~/.ssh` at `700` and `authorized_keys` at `600`.

## Limits

- `setup` supports apt and systemd only. A macOS remote needs Remote Login enabled by hand (System Settings → General → Sharing); `enroll` works against it, but hardening is skipped for it.
- `enroll` leaves an existing `Host <name>` block untouched; edit it by hand if it is stale.
