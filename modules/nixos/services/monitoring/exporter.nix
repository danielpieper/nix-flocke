{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.monitoring;
in
{
  options.services.flocke.monitoring = {
    enable_exporter = mkEnableOption "Enable The monitoring systemd prometheus exporter";
  };

  config = mkIf cfg.enable_exporter {
    services.prometheus.exporters.node = {
      port = 3021;
      enabledCollectors = [ "systemd" ];
      enable = true;
    };
  };
}
