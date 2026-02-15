{
  inputs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.evitts;
in
{
  imports = [ inputs.evitts.nixosModules.default ];

  options.services.flocke.evitts = {
    enable = mkEnableOption "Enable evitts";
  };

  config = mkIf cfg.enable {
    sops.secrets.evitts_env = { };
    systemd.services.evitts = {
      unitConfig = {
        RequiresMountsFor = "/mnt/nas/11tb";
      };
      serviceConfig = {
        ReadWritePaths = [ "/mnt/nas/11tb/Evi/Syncthing/tts" ];
      };
    };
    services = {
      evitts = {
        enable = true;
        watchDirectory = "/mnt/nas/11tb/Evi/Syncthing/tts";
        environment = {
          AWS_POLLY_VOICE = "Daniel";
          SERVER_PORT = "8093";
          AWS_COMPREHEND_ENABLED = "true";
          MAX_CHARS_PER_PART = "95000";
        };
        environmentFile = config.sops.secrets.evitts_env.path;
      };
      traefik = {
        dynamic.files."evitts".settings = {
          http = {
            services = {
              evitts.loadBalancer.servers = [ { url = "http://localhost:8093"; } ];
            };

            routers = {
              evitts = {
                entryPoints = [ "websecure" ];
                rule = "Host(`evitts.homelab.${inputs.nix-secrets.domain}`)";
                service = "evitts";
              };
            };
          };
        };
      };
    };
  };
}
