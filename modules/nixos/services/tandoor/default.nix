{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.tandoor;
in
{
  options.services.flocke.tandoor = {
    enable = mkEnableOption "Enable the tandoor recipe service";
  };

  config = mkIf cfg.enable {
    sops.secrets.tandoor = { };

    systemd.services.tandoor-recipes = {
      serviceConfig = {
        EnvironmentFile = [ config.sops.secrets.tandoor.path ];
      };
      after = [ "postgresql.service" ];
    };

    users.users.nginx.extraGroups = [ "tandoor_recipes" ];

    services = {
      tandoor-recipes = {
        enable = true;
        port = 8099;
        extraConfig = {
          DB_ENGINE = "django.db.backends.postgresql";
          POSTGRES_HOST = "/run/postgresql";
          POSTGRES_USER = "tandoor_recipes";
          POSTGRES_DB = "tandoor_recipes";
          # TODO: https://github.com/TandoorRecipes/recipes/issues/3596
          # SOCIAL_DEFAULT_GROUP = "user";
          # SOCIAL_PROVIDERS = "allauth.socialaccount.providers.openid_connect";
        };
      };

      postgresql = {
        ensureDatabases = [ "tandoor_recipes" ];
        ensureUsers = [
          {
            name = "tandoor_recipes";
            ensureDBOwnership = true;
          }
        ];
      };

      nginx = {
        enable = true;
        virtualHosts = {
          "tandoor-media" = {
            listen = [
              {
                addr = "localhost";
                port = 8100;
              }
            ];
            locations = {
              "/media/" = {
                alias = "/var/lib/tandoor-recipes/";
              };
            };
          };
        };
      };

      traefik = {
        dynamicConfigOptions = {
          http = {
            services = {
              tandoor.loadBalancer.servers = [
                {
                  url = "http://localhost:8099";
                }
              ];
              tandoor-media.loadBalancer.servers = [
                {
                  url = "http://localhost:8100";
                }
              ];
            };

            routers = {
              tandoor = {
                entryPoints = [ "websecure" ];
                rule = "Host(`tandoor.homelab.${inputs.nix-secrets.domain}`)";
                service = "tandoor";
                tls.certResolver = "letsencrypt";
              };
              tandoor-media = {
                entryPoints = [ "websecure" ];
                rule = "Host(`tandoor.homelab.${inputs.nix-secrets.domain}` && PathPrefix(`/media/)";
                service = "tandoor-media";
                tls.certResolver = "letsencrypt";
              };
            };
          };
        };
      };
    };
  };
}
