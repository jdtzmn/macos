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
