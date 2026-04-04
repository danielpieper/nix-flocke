{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.restic;
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

    backupPrepareCommand = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Command to run before backup (e.g. database dump)";
    };
  };

  config = mkIf cfg.enable {
    users.groups.restic-backup = { };

    sops.secrets = {
      restic_repository_password.group = "restic-backup";
      restic_repository.group = "restic-backup";
      restic_environment.group = "restic-backup";
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
      Match host *.your-storagebox.de
        Port 23
        IdentityFile /persist/etc/ssh/restic_ed25519
        StrictHostKeyChecking accept-new
    '';

    systemd.tmpfiles.rules = [
      "d /persist/var/backup 0750 root root -"
      "z /persist/etc/ssh/restic_ed25519 0640 root restic-backup -"
    ];

    services.restic.backups.default = {
      repositoryFile = config.sops.secrets.restic_repository.path;
      initialize = false;
      passwordFile = config.sops.secrets.restic_repository_password.path;
      environmentFile = config.sops.secrets.restic_environment.path;
      inherit (cfg) paths backupPrepareCommand;
      extraBackupArgs = [
        "--no-scan"
        "--exclude-caches"
        "--exclude=.cache"
        "--exclude=var/cache"
      ]
      ++ map (e: "--exclude=${e}") cfg.excludes;
      pruneOpts = [
        "--keep-within 2d"
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
        "--keep-yearly 3"
      ];
      timerConfig = {
        OnCalendar = "00:05";
        RandomizedDelaySec = "5h";
      };
    };

    # see https://github.com/NixOS/nixpkgs/issues/196547#issuecomment-2044540904
    systemd.services."restic-backups-default" = {
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "60s";
      };
      unitConfig = {
        StartLimitIntervalSec = 3600;
        StartLimitBurst = 15;
      };
    };
  };
}
