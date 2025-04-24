{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.restic;
in
{
  options.services.flocke.restic = {
    enable = mkEnableOption "Enable the restic backup client";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      restic_repository_password = {
        owner = inputs.nix-secrets.user.name;
      };
      restic_repository = {
        owner = inputs.nix-secrets.user.name;
      };
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

    services.restic.backups.default = {
      repository = "rest:https://restic.homelab.${inputs.nix-secrets.domain}";
      initialize = true;
      passwordFile = config.sops.secrets.restic_repository_password.path;
      environmentFile = config.sops.secrets.restic_environment.path;
      paths = [
        "/persist"
        "/home"
      ];
      extraBackupArgs = [
        "--no-scan"
        "--exclude-caches"
        # /home excludes:
        "--exclude=.local/share/containers"
        "--exclude=steamapps"
        "--exclude=games"
        # /persist excludes:
        "--exclude=valheim_server_Data"
        "--exclude=satisfactory/FactoryGame"
        "--exclude=satisfactory/Engine"
        "--exclude=var/lib/docker"
        "--exclude=var/lib/containers"
        "--exclude=var/lib/arr"
        "--exclude=var/lib/loki"
        "--exclude=jellyfin/metadata"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 75"
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
