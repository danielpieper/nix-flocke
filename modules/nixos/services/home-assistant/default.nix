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
      containers = {
        # https://www.home-assistant.io/installation/linux#install-home-assistant-container
        homeassistant = {
          pull = "newer";
          privileged = true;
          volumes = [ "home-assistant:/config" ];
          environment.TZ = "Europe/Berlin";
          image = "ghcr.io/home-assistant/home-assistant:stable";
          extraOptions = [
            "--network=host"
            # "--cap-add=NET_ADMIN"
            # "--cap-add=NET_RAW"
            # "--cap-add=CAP_NET_BIND_SERVICE"
            # "--device=/dev/ttyACM0:/dev/ttyACM0"
          ];
        };
      };
    };

    services = {
      matter-server = {
        enable = true;
        # logLevel = "debug";
        port = 5580;
      };
      traefik = {
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
  };
}
