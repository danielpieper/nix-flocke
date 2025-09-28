{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.n8n;
in
{
  imports = [
    ./webhook.nix
  ];

  options.services.flocke.n8n = {
    enable = mkEnableOption "Enable n8n";
  };

  config = mkIf cfg.enable {
    services = {
      n8n = {
        enable = true;
        openFirewall = true; # TODO: is this needed behind reverse proxy?
        webhookUrl = "https://n8nhook.${inputs.nix-secrets.domain}";
      };
      traefik = {
        dynamicConfigOptions = {
          http = {
            services = {
              n8n.loadBalancer.servers = [
                {
                  url = "http://localhost:5678";
                }
              ];
            };
            routers = {
              n8n = {
                entryPoints = [ "websecure" ];
                rule = "Host(`n8n.homelab.${inputs.nix-secrets.domain}`)";
                service = "n8n";
              };
            };
          };
        };
      };
    };
    systemd.services.n8n.environment = {
      # TODO: https://docs.n8n.io/user-management/best-practices/#all-platforms
      N8N_PROXY_HOPS = "1";
    };
  };
}
