{
  config,
  lib,
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
          bootstrap_dns = [
            "8.8.8.8"
            "1.1.1.1"
          ];
          upstream_dns = [
            # google
            "8.8.8.8"
            "8.8.4.4"
            "2001:4860:4860::8888"
            "2001:4860:4860::8844"
            "https://dns.google/dns-query"
            "tls://dns.google"
            # cloudflare
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
            "https://dns.cloudflare.com/dns-query"
            "tls://1dot1dot1dot1.cloudflare-dns.com"
            # quad9
            "9.9.9.9"
            "149.112.112.112"
            "2620:fe::fe"
            "2620:fe::fe:9"
            "https://dns.quad9.net/dns-query"
            "tls://dns.quad9.net"
          ];
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
              rule = "Host(`adguard.homelab.daniel-pieper.com`)";
              service = "adguardhome";
              tls.certResolver = "letsencrypt";
            };
          };
        };
      };
    };
  };
}
