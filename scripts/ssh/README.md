# SSH into a new Linux machine with 1Password

Two scripts that bring up a Debian/Ubuntu box and let you reach it with a key
held in the 1Password SSH agent. The private key never leaves 1Password; the
remote only gets the public half.

| Script | Runs on | Does |
| --- | --- | --- |
| `setup` | the Linux machine | installs and enables `openssh-server`, prepares `~/.ssh`; `--harden` disables password and root login |
| `enroll` | your Mac | finds the key in the 1Password agent, installs its public key on the remote, adds a `Host` block to `~/.ssh/config`, verifies key login |

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
   Run it bare to be prompted for the name, host, username and (if no title matches) a key from a numbered list. `name` is the alias for `ssh build-box`. The key is matched by title: the default is the name with `-`/`_` as spaces (`build box` for `build-box`). Use `--key "<text>"` when the title differs. You are asked for the remote password once.
4. **Check** `ssh build-box` works and prompts for Touch ID.
5. **Harden**, with the existing session still open:
   ```bash
   scripts/ssh/setup --harden
   ```
   Then confirm a fresh `ssh build-box` from a second terminal.

## Troubleshooting

- **`no key matching ...`**: the key is not in the agent. Check the vault and `agent.toml`, then `SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ssh-add -l`.
- **`Too many authentication failures`**: the host entry needs `IdentitiesOnly yes` and an `IdentityFile` pointing at the `.pub`; `enroll` writes both.
- **Key login fails after install**: unlock 1Password, and check the remote has `~/.ssh` at `700` and `authorized_keys` at `600`.

## Limits

- `setup` supports apt and systemd only.
- `enroll` leaves an existing `Host <name>` block untouched; edit it by hand if it is stale.
