{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.otelcol;
in
{
  options.services.flocke.otelcol = {
    enable = mkEnableOption "OpenTelemetry Collector — local agent that batches OTLP and forwards to the central trace backend";

    exporterEndpoint = mkOption {
      type = types.str;
      default = "jarvis:4317";
      description = ''
        OTLP gRPC endpoint of the central trace backend (Tempo), reached over
        the tailnet. Plaintext is fine — the tailnet is WireGuard-encrypted.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Local agent: apps on this host export to 127.0.0.1:4317 (the projectz
    # default); the collector batches and ships everything to Tempo on jarvis.
    # Receivers stay on localhost — nothing is exposed off-box.
    services.opentelemetry-collector = {
      enable = true;
      package = pkgs.opentelemetry-collector;
      settings = {
        receivers.otlp.protocols = {
          grpc.endpoint = "127.0.0.1:4317";
          http.endpoint = "127.0.0.1:4318";
        };
        processors.batch = { };
        exporters.otlp = {
          endpoint = cfg.exporterEndpoint;
          tls.insecure = true;
        };
        service.pipelines.traces = {
          receivers = [ "otlp" ];
          processors = [ "batch" ];
          exporters = [ "otlp" ];
        };
      };
    };
  };
}
