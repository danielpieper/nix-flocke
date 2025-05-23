{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.home-assistant;
in
{
  options.services.flocke.home-assistant = {
    enable = mkEnableOption "Enable Home Assistant";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        pull = "newer";
        ports = [ "127.0.0.1:8123:8123" ];
        volumes = [ "home-assistant:/config" ];
        environment.TZ = "Europe/Berlin";
        image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
        extraOptions = [
          "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE"
          # "--device=/dev/ttyACM0:/dev/ttyACM0" # Example, change this to match your own hardware
        ];
      };
    };

    services.traefik = {
      dynamicConfigOptions = {
        http = {
          services = {
            home-assistant.loadBalancer.servers = [
              {
                url = "http://127.0.0.1:8123";
              }
            ];
          };

          routers = {
            home-assistant = {
              entryPoints = [ "websecure" ];
              rule = "Host(`home.homelab.${inputs.nix-secrets.domain}`)";
              service = "home-assistant";
            };
          };
        };
      };
    };
  };
}
