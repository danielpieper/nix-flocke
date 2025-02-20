{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.monitoring;
  textfileCollectorDir = "/var/cache/metrics";
  mullvadPrometheusExporter = pkgs.writeShellApplication {
    name = "mullvad-prometheus-exporter";
    runtimeInputs = [
      pkgs.curl
    ];
    text = ''
      PROM_FILE="${textfileCollectorDir}/mullvad.prom"
      echo "mullvad_connected 0" > $PROM_FILE

      STATUS=$(curl -s https://am.i.mullvad.net/connected)
      if echo "$STATUS" | grep -qE "You are connected to Mullvad"; then
          echo "mullvad_connected 1" > $PROM_FILE
      else
          echo "mullvad_connected 0" > $PROM_FILE
      fi
    '';
  };
in
{
  options.services.flocke.monitoring = {
    enable_mullvad = mkEnableOption "Enable mullvad connection status monitoring";
  };

  config = mkIf cfg.enable_mullvad {
    systemd = {
      tmpfiles.rules = [
        "d ${textfileCollectorDir} 0777 root root"
      ];
      services.mullvad-exporter = {
        description = "Mullvad VPN Prometheus Exporter";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${mullvadPrometheusExporter}/bin/mullvad-prometheus-exporter";
          User = "root"; # TODO: run without root permissions
          Group = "root";
        };
      };
      timers.mullvad-exporter = {
        description = "Run Mullvad Exporter every 10 minutes";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "30s";
          OnUnitActiveSec = "10m";
          AccuracySec = "5s";
          Persistent = true;
        };
      };
    };
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [
        "textfile"
        "textfile.directory=${textfileCollectorDir}"
      ];
    };
  };
}
