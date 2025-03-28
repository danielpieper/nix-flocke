{ config
, lib
, inputs
, ...
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
    sops.secrets.authentik_env = { };

    services = {
      authentik = {
        enable = true;
        environmentFile = config.sops.secrets.authentik_env.path;
        settings = {
          email = {
            host = inputs.nix-secrets.mailgun.host;
            port = inputs.nix-secrets.mailgun.port;
            username = inputs.nix-secrets.mailgun.username;
            use_tls = true;
            use_ssl = false;
            from = inputs.nix-secrets.mailgun.fromEmail;
          };
          disable_startup_analytics = true;
          avatars = "initials";
        };
      };

      cloudflared = {
        tunnels = {
          "${inputs.nix-secrets.cloudflare.tunnelID}" = {
            ingress = {
              "authentik.${inputs.nix-secrets.domain}" = "http://localhost:9000";
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
                rule = "Host(`authentik.${inputs.nix-secrets.domain}`) || HostRegexp(`{subdomain:[a-z0-9]+}.homelab.${inputs.nix-secrets.domain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
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
