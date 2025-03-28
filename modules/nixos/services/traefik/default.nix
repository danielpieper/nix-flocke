{ config
, lib
, inputs
, ...
}:
with lib;
let
  cfg = config.services.flocke.traefik;
in
{
  options.services.flocke.traefik = {
    enable = mkEnableOption "Enable traefik";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    systemd = {
      tmpfiles.rules = [
        "d /var/log/traefik 0755 traefik traefik"
      ];

      services.traefik = {
        environment.CF_API_EMAIL = inputs.nix-secrets.cloudflare.email;
        serviceConfig.EnvironmentFile = [ config.sops.secrets.cloudflare_api_key.path ];
      };
    };

    sops.secrets.cloudflare_api_key = { };

    services = {
      tailscale.permitCertUid = "traefik";

      traefik = {
        enable = true;

        staticConfigOptions = {
          log = {
            level = "INFO";
            filePath = "/var/log/traefik/traefik.log";
            # format = "json";  # Uses text format (common) by default
            noColor = false;
            maxSize = 100;
            compress = true;
          };

          metrics = {
            prometheus = { };
          };

          # tracing = {};

          accessLog = {
            addInternals = true;
            filePath = "/var/log/traefik/access.log";
            bufferingSize = 100; # Number of log lines
            fields = {
              names = {
                StartUTC = "drop"; # Write logs in Container Local Time instead of UTC
              };
            };
            filters = {
              statusCodes = [
                "204-299"
                "400-499"
                "500-599"
              ];
            };
          };
          api = {
            dashboard = true;
            insecure = true;
          };
          certificatesResolvers = {
            tailscale.tailscale = { };
            letsencrypt = {
              acme = {
                email = inputs.nix-secrets.cloudflare.email;
                storage = "/var/lib/traefik/cert.json";
                dnsChallenge = {
                  provider = "cloudflare";
                  resolvers = [
                    "1.1.1.1:53"
                    "8.8.8.8:53"
                  ];
                  disablePropagationCheck = true;
                  delayBeforeCheck = 60;
                };
              };
            };
          };
          entryPoints.web = {
            address = "0.0.0.0:80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
              permanent = true;
            };
          };
          entryPoints.websecure = {
            address = "0.0.0.0:443";
            http.tls = {
              certResolver = "letsencrypt";
              domains = [
                {
                  main = "homelab.${inputs.nix-secrets.domain}";
                  sans = [ "*.homelab.${inputs.nix-secrets.domain}" ];
                }
                {
                  main = inputs.nix-secrets.domain;
                  sans = [ "*.${inputs.nix-secrets.domain}" ];
                }
              ];
            };
          };
        };
      };
    };
  };
}
