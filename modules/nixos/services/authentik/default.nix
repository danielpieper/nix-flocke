{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.authentik;
in
{
  options.services.flocke.authentik = {
    enable = mkEnableOption "Enable the authentik auth service";
  };

  config = mkIf cfg.enable {
    sops.secrets.authentik_env = {
      sopsFile = ../secrets.yaml;
    };

    services = {
      authentik = {
        enable = true;
        environmentFile = config.sops.secrets.authentik_env.path;
        settings = {
          email = {
            host = "smtp.eu.mailgun.org";
            port = 587;
            username = "postmaster@mail.daniel-pieper.com";
            use_tls = true;
            use_ssl = false;
            from = "homelab@daniel-pieper.com";
          };
          disable_startup_analytics = true;
          avatars = "initials";
        };
      };

      cloudflared = {
        tunnels = {
          "4488062b-53ae-4932-ba43-db4804831f8a" = {
            ingress = {
              "authentik.daniel-pieper.com" = "http://localhost:9000";
            };
          };
        };
      };

      traefik = {
        dynamicConfigOptions = {
          http = {
            middlewares = {
              authentik = {
                forwardAuth = {
                  tls.insecureSkipVerify = true;
                  address = "https://localhost:9443/outpost.goauthentik.io/auth/traefik";
                  trustForwardHeader = true;
                  authResponseHeaders = [
                    "X-authentik-username"
                    "X-authentik-groups"
                    "X-authentik-email"
                    "X-authentik-name"
                    "X-authentik-uid"
                    "X-authentik-jwt"
                    "X-authentik-meta-jwks"
                    "X-authentik-meta-outpost"
                    "X-authentik-meta-provider"
                    "X-authentik-meta-app"
                    "X-authentik-meta-version"
                  ];
                };
              };
            };

            services = {
              auth.loadBalancer.servers = [
                {
                  url = "http://localhost:9000";
                }
              ];
            };

            routers = {
              auth = {
                entryPoints = [ "websecure" ];
                rule = "Host(`authentik.daniel-pieper.com`) || HostRegexp(`{subdomain:[a-z0-9]+}.homelab.daniel-pieper.com`) && PathPrefix(`/outpost.goauthentik.io/`)";
                service = "auth";
                tls.certResolver = "letsencrypt";
              };
            };
          };
        };
      };
    };
  };
}
