{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.adguard;
in
{
  options.services.flocke.adguard = {
    enable = mkEnableOption "Enable AdGuard Home";
  };

  config = mkIf cfg.enable {
    networking.firewall = lib.mkForce {
      enable = true;
      allowedUDPPorts = [
        53
      ];

      allowedTCPPorts = [
        53
      ];
    };

    services.adguardhome = {
      enable = true;
      openFirewall = true;
      allowDHCP = true;
      settings = {
        dns = {
          bind_hosts = [ "0.0.0.0" ];
          bootstrap_dns = inputs.nix-secrets.networking.fallbackNameservers;
          upstream_dns = inputs.nix-secrets.adguardhome.nameservers;
          ratelimit = 0;
          safe_search = {
            enabled = true;
            bing = true;
            duckduckgo = false;
            google = true;
            pixabay = true;
            yandex = true;
            youtube = true;
          };
        };
        querylog = {
          enabled = true;
          interval = "3h";
        };
        user_rules = [
          # allow roblox
          "@@||roblox.com^"
        ];
      };
    };

    services.traefik = {
      dynamicConfigOptions = {
        http = {
          services = {
            adguardhome.loadBalancer.servers = [
              {
                url = "http://localhost:3000";
              }
            ];
          };

          routers = {
            adguardhome = {
              entryPoints = [ "websecure" ];
              rule = "Host(`adguard.homelab.${inputs.nix-secrets.domain}`)";
              service = "adguardhome";
              tls.certResolver = "letsencrypt";
            };
          };
        };
      };
    };
  };
}
