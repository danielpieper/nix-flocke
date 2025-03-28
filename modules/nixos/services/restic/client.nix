{ pkgs
, config
, lib
, inputs
, ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.restic;
  textfileCollectorDir = "/var/cache/metrics";

  resticPrometheusExporter = pkgs.writeShellApplication {
    name = "restic-prometheus-exporter";
    runtimeInputs = [
      pkgs.jq
      pkgs.restic
    ];
    text = ''
      # Create a temp unique file, that will not be parsed by node exporter.
      TEMP_FILE="${textfileCollectorDir}/restic.prom.$$"
      PERM_FILE="${textfileCollectorDir}/restic.prom"
      touch ''${TEMP_FILE}

      # Note the start time of the script.
      START="$(date +%s)"

      set -a # automatically export all variables
      # TODO: is disabling spell check the right thing to do???
      # shellcheck disable=SC1091
      source ${config.sops.secrets.restic_environment.path}
      set +a

      # Get last backup timestamp
      RESTIC_PASSWORD_FILE=${config.sops.secrets.restic_repository_password.path} restic -r rest:https://restic.homelab.${inputs.nix-secrets.domain} snapshots latest --json | jq -r 'max_by(.time) | .time | sub("[.][0-9]+"; "") | sub("Z"; "+00:00") | def parseDate(date): date | capture("(?<no_tz>.*)(?<tz_sgn>[-+])(?<tz_hr>\\d{2}):(?<tz_min>\\d{2})$") | (.no_tz + "Z" | fromdateiso8601) - (.tz_sgn + "60" | tonumber) * ((.tz_hr | tonumber) * 60 + (.tz_min | tonumber)); parseDate(.) | "restic_last_snapshot_ts \(.)"' >> ''${TEMP_FILE}
      # Get last backup size in bytes and files count
      RESTIC_PASSWORD_FILE=${config.sops.secrets.restic_repository_password.path} restic -r rest:https://restic.homelab.${inputs.nix-secrets.domain} stats latest --json | jq -r '"restic_stats_total_size_bytes \(.total_size)\nrestic_stats_total_file_count \(.total_file_count)"' >> ''${TEMP_FILE}

      # Write out metrics to a temporary file.
      END="$(date +%s)"
      echo "restic_collector_duration_seconds $((END - START))" >> ''${TEMP_FILE}
      echo "restic_collector_last_run_ts ''${END}" >> ''${TEMP_FILE}

      # Rename the temporary file atomically.
      # This avoids the node exporter seeing half a file.
      # In case a temp file was not created, delete the permanent file,
      # to avoid outdated metrics.
      mv "''${TEMP_FILE}" "''${PERM_FILE}" || rm "''${PERM_FILE}"
    '';
  };
in
{
  options.services.flocke.restic = {
    enable = mkEnableOption "Enable the restic backup client";
  };

  config = mkIf cfg.enable {
    services.restic.backups = {
      default = {
        repository = "rest:https://restic.homelab.${inputs.nix-secrets.domain}";
        initialize = true;
        passwordFile = config.sops.secrets.restic_repository_password.path;
        environmentFile = config.sops.secrets.restic_environment.path;
        paths = [
          "/persist"
        ];
        extraBackupArgs = [
          "--no-scan"
          "--exclude-caches"
          "--exclude=steamapps"
          "--exclude=valheim_server_data"
          "--exclude=satisfactory/FactoryGame"
          "--exclude=satisfactory/Engine"
          "--exclude=var/lib/docker"
          "--exclude=games"
        ];
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 75"
        ];
        backupCleanupCommand = "${resticPrometheusExporter}/bin/restic-prometheus-exporter";
        timerConfig = {
          OnCalendar = "00:05";
          RandomizedDelaySec = "5h";
        };
      };
    };
    systemd.tmpfiles.rules = [
      "d ${textfileCollectorDir} 0777 root root"
    ];

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

    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [
        "textfile"
        "textfile.directory=${textfileCollectorDir}"
      ];
    };

    sops.secrets = {
      restic_repository_password = { };
      restic_environment = { };
    };

  };
}
