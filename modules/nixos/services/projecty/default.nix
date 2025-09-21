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
        inherit (inputs.nix-secrets.projecty) environment;
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
        dynamicConfigOptions = {
          http = {
            services = {
              projecty.loadBalancer.servers = [ { url = "http://localhost:8081"; } ];
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
