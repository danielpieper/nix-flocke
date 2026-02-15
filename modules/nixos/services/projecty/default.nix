{
  inputs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.projecty;
in
{
  imports = [ inputs.projecty.nixosModules.default ];

  options.services.flocke.projecty = {
    enable = mkEnableOption "Enable projecty";
  };

  config = mkIf cfg.enable {
    services = {
      projecty = {
        enable = true;
        # TODO: add secrets here:
        # environmentFile = config.sops.secrets.projecty.path;
        environment = inputs.nix-secrets.projecty.environment // {
          PROJECTY_HTTP_ADDR = ":8083"; # Changed from default :8080 to avoid conflict with OTBR (runs on 8081)
        };
      };
      # use peer auth for example:
      # sudo -u postgres psql
      postgresql = {
        ensureDatabases = [
          "kratos"
          "projecty"
        ];
        ensureUsers = [
          {
            name = "kratos";
            ensureDBOwnership = true;
          }
          {
            name = "projecty";
            ensureDBOwnership = true;
          }
        ];
      };
      traefik = {
        dynamic.files."projecty".settings = {
          http = {
            services = {
              projecty.loadBalancer.servers = [ { url = "http://localhost:8083"; } ];
            };

            routers = {
              projecty = {
                entryPoints = [ "websecure" ];
                rule = "Host(`projecty.homelab.${inputs.nix-secrets.domain}`)";
                service = "projecty";
              };
            };
          };
        };
      };
      flocke = {
        postgresql.enable = true;
        kratos = {
          enable = true;
          inherit (inputs.nix-secrets.projecty.kratos) settings;
          inherit (inputs.nix-secrets.projecty.kratos) identitySchema;
        };
      };
    };
  };
}
