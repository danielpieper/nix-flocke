{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.openwebui;
in
{
  options.services.flocke.openwebui = {
    enable = mkEnableOption "Enable the Open-WebUI server";
  };

  config = mkIf cfg.enable {
    services = {
      open-webui = {
        enable = true;
        port = 8998;
      };
      litellm = {
        enable = true;
      };
      traefik = {
        dynamic.files."openwebui".settings = {
          http = {
            services = {
              openwebui.loadBalancer.servers = [
                {
                  url = "http://localhost:8998";
                }
              ];
            };

            routers = {
              openwebui = {
                entryPoints = [ "websecure" ];
                rule = "Host(`ai.homelab.${inputs.nix-secrets.domain}`)";
                service = "openwebui";
              };
            };
          };
        };
      };
    };
  };
}
