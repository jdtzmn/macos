{
  pkgs,
  repoDir ? null,
  username ? "jacob",
  homeDirectory ? "/home/jacob",
  ...
}:
{
    imports = [
        ../../shared/index.nix
    ];

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    home = {
        inherit username homeDirectory;
        stateVersion = "25.11";
    };

    ##############################
    # Linux-specific Git Configuration
    ##############################

    # Ensures Nix's own profile (~/.nix-profile/bin) and home-manager's
    # session vars get sourced on every shell, even outside NixOS. Needed in
    # particular for single-user Nix installs (e.g. devpod/devcontainer
    # sandboxes, which have no systemd to run a multi-user nix-daemon):
    # without this, home-manager's activation overwrites ~/.profile/~/.bashrc
    # and drops whatever PATH setup the Nix installer added there.
    targets.genericLinux.enable = true;
    # GPU driver detection isn't needed in a headless devcontainer, and
    # pulls in x86_64-only packages (e.g. intel-gmmlib) that fail to
    # evaluate on aarch64-linux (e.g. OrbStack's native arm64 containers).
    targets.genericLinux.gpu.enable = false;

    # Enable bash to launch fish interactively
    programs.bash = {
        enable = true;
        bashrcExtra = ''
            # Launch fish for interactive shells
            if [ -n "$PS1" ]; then
              if command -v fish &> /dev/null; then
                exec fish
              fi
            fi
        '';
    };
    programs.zsh.enable = false;

    ##############################
    # Scheduled maintenance
    ##############################

    # Daily Docker prune via systemd user timer.
    # Note: user timers only run while the user has an active session unless
    # `loginctl enable-linger <user>` has been set (one-time, manual).
    systemd.user.services.docker-prune = {
        Unit = {
            Description = "Prune unused Docker resources";
        };
        Service = {
            Type = "oneshot";
            # Split into two steps: docker rejects `--volumes` together with
            # the `until` filter, so we time-filter the system prune and then
            # prune dangling volumes separately. systemd runs ExecStart entries
            # in order under Type=oneshot.
            ExecStart = [
                "${pkgs.docker}/bin/docker system prune -af --filter until=168h"
                "${pkgs.docker}/bin/docker volume prune -af"
            ];
        };
    };

    systemd.user.timers.docker-prune = {
        Unit = {
            Description = "Daily Docker prune timer";
        };
        Timer = {
            OnCalendar = "daily";
            Persistent = true;          # run on next boot if the machine was off
            RandomizedDelaySec = "30m";
        };
        Install = {
            WantedBy = [ "timers.target" ];
        };
    };
}
