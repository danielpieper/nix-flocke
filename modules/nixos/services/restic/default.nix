{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.restic;

  repoSettings = {
    repositoryFile = config.sops.secrets.restic_repository.path;
    initialize = false;
    passwordFile = config.sops.secrets.restic_repository_password.path;
    environmentFile = config.sops.secrets.restic_environment.path;
  };
in
{
  imports = [ ./exporter.nix ];

  options.services.flocke.restic = {
    enable = mkEnableOption "Enable the restic backup client";

    paths = mkOption {
      type = types.listOf types.str;
      default = [
        "/persist"
        "/home"
      ];
      description = "Paths to back up";
    };

    excludes = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Paths to exclude from backup";
    };

    maintenance = mkEnableOption ''
      repo-wide forget/prune. `restic forget` applies the retention policy to
      every host's snapshots, not just the local one, so exactly one always-on
      host should enable this
    '';

    backupPrepareCommand = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Command to run before backup (e.g. database dump)";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      restic_repository_password = { };
      restic_repository = { };
      restic_environment = { };
    };

    environment = {
      sessionVariables = {
        RESTIC_REPOSITORY_FILE = config.sops.secrets.restic_repository.path;
        RESTIC_PASSWORD_FILE = config.sops.secrets.restic_repository_password.path;
      };
      systemPackages = with pkgs; [
        restic
        redu
      ];
    };

    programs.ssh.extraConfig = ''
      Host ${inputs.nix-secrets.storageBox.restic.host}
        Port 23
        User ${inputs.nix-secrets.storageBox.restic.username}
        IdentityFile /persist/etc/ssh/restic_ed25519
        IdentityFile /persist/etc/ssh/restic-exporter_ed25519
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes
        StrictHostKeyChecking accept-new
    '';

    systemd.tmpfiles.rules = [
      "d /persist/var/backup 0750 root root -"
      "z /persist/etc/ssh/restic_ed25519 0600 root root -"
    ];

    services.restic.backups = mkMerge [
      {
        default = repoSettings // {
          inherit (cfg) paths backupPrepareCommand;
          extraBackupArgs = [
            "--no-scan"
            # Wait out a repo that is busy rather than failing instantly: the
            # hosts share one repository and prune takes an exclusive lock.
            "--retry-lock 30m"
            "--exclude-caches"
            "--exclude=.cache"
            "--exclude=var/cache"
          ]
          ++ map (e: "--exclude=${e}") cfg.excludes;
          # Deliberately empty: forget/prune is repo-wide, not per-host, so it
          # runs on one always-on host instead (cfg.maintenance) rather than
          # four times a night from machines that may suspend mid-repack.
          pruneOpts = [ ];
          timerConfig = {
            OnCalendar = "00:05";
            RandomizedDelaySec = "5h";
          };
        };
      }

      (mkIf cfg.maintenance {
        # Prune-only job: with no paths the upstream module emits an ExecStart
        # of `restic unlock` followed by `restic forget --prune`, so stale-lock
        # cleanup runs first and unconditionally -- it is no longer stranded
        # behind a backup that the lock itself is blocking.
        maintenance = repoSettings // {
          paths = [ ];
          pruneOpts = [
            "--retry-lock 30m"
            "--keep-within 2d"
            "--keep-daily 7"
            "--keep-weekly 4"
            "--keep-monthly 12"
            "--keep-yearly 3"
          ];
          # The 00:05 + 5h jitter window has closed by now, so the nightly
          # backups have landed.
          timerConfig = {
            OnCalendar = "07:00";
            RandomizedDelaySec = "30m";
          };
        };
      })
    ];

    # see https://github.com/NixOS/nixpkgs/issues/196547#issuecomment-2044540904
    systemd.services = mkMerge [
      {
        "restic-backups-default" = {
          serviceConfig = {
            Restart = "on-failure";
            RestartSec = "60s";
          };
          unitConfig = {
            StartLimitIntervalSec = 3600;
            StartLimitBurst = 15;
          };
        };
      }
      (mkIf cfg.maintenance {
        "restic-backups-maintenance" = {
          serviceConfig = {
            Restart = "on-failure";
            RestartSec = "60s";
          };
          unitConfig = {
            StartLimitIntervalSec = 3600;
            StartLimitBurst = 15;
          };
        };
      })
    ];
  };
}
