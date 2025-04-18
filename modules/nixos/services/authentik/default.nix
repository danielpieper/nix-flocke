{
  config,
  lib,
  inputs,
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
    sops.secrets.authentik_env = { };

    services = {
      # See https://github.com/brokenscripts/authentik_traefik/tree/traefik3?tab=readme-ov-file
      authentik = {
        enable = true;
        environmentFile = config.sops.secrets.authentik_env.path;
        settings = {
          email = {
            inherit (inputs.nix-secrets.mailgun)
              host
              port
              username
              from
              ;
            use_tls = true;
            use_ssl = false;
          };
          disable_startup_analytics = true;
          avatars = "initials";
        };
      };

      traefik = {
        dynamicConfigOptions = {
          http = {
            middlewares = {
              authentik = {
                forwardAuth = {
                  address = "http://localhost:9000/outpost.goauthentik.io/auth/traefik";
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
                rule = "Host(`authentik.homelab.${inputs.nix-secrets.domain}`)";
                service = "auth";
              };
            };
          };
        };
      };
    };
  };
}
