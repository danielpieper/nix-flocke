{
  config,
  lib,
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
    sops.secrets.tandoor = {
      sopsFile = ../secrets.yaml;
    };

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
          SOCIAL_DEFAULT_GROUP = "user";
          SOCIAL_PROVIDERS = "allauth.socialaccount.providers.openid_connect";
        };
      };

      cloudflared = {
        tunnels = {
          "4488062b-53ae-4932-ba43-db4804831f8a" = {
            ingress = {
              "tandoor.daniel-pieper.com/media/" = "http://localhost:8100";
              "tandoor.daniel-pieper.com" = "http://localhost:8099";
            };
          };
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
          "recipes-media" = {
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
    };
  };
}
