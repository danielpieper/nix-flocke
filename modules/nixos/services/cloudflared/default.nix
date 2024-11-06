{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.cloudflared;
in
{
  options.services.flocke.cloudflared = {
    enable = mkEnableOption "Enable The cloudflared (tunnel) service";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      cloudflared = {
        sopsFile = ../secrets.yaml;
        owner = "cloudflared";
      };
      cloudflared-cert = {
        sopsFile = ../secrets.yaml;
        owner = "cloudflared";
      };
    };

    environment.etc."cloudflared/cert.pem" = {
      user = "cloudflared";
      group = "cloudflared";
      source = config.sops.secrets.cloudflared-cert.path;
    };

    services = {
      cloudflared = {
        enable = true;
        tunnels = {
          "4488062b-53ae-4932-ba43-db4804831f8a" = {
            credentialsFile = config.sops.secrets.cloudflared.path;
            default = "http_status:404";
          };
        };
      };
    };
  };
}
