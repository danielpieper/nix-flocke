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
  options.services.flocke.n8n = {
    enableWebhook = mkEnableOption "Enable n8n webhook";
  };

  config = mkIf cfg.enableWebhook {
    services.traefik = {
      dynamic.files."n8n-webhook".settings = {
        http = {
          services = {
            n8nwebhook.loadBalancer = {
              passHostHeader = false;
              servers = [
                {
                  url = "https://n8n.homelab.${inputs.nix-secrets.domain}";
                }
              ];
            };
          };
          routers = {
            n8nwebhook = {
              entryPoints = [ "websecure" ];
              rule = "Host(`n8nhook.${inputs.nix-secrets.domain}`) && (PathPrefix(`/webhook`) || PathPrefix(`/rest/oauth2`) )";
              service = "n8nwebhook";
            };
          };
        };
      };
    };
  };
}
