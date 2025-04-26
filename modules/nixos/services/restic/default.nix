{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.restic;
in
{
  imports = [
    ./client.nix
  ];

  options.services.flocke.restic = {
    enable_server = mkEnableOption "Enable the restic backup server";
  };

  config = mkIf cfg.enable_server {
    # https://github.com/restic/rest-server
    services = {
      restic.server = {
        enable = true;
        listenAddress = "127.0.0.1:8012";
        inherit (inputs.nix-secrets.restic) dataDir;
        # TODO: check if restic settings should be enabled
        privateRepos = false;
        appendOnly = false;
      };

      traefik = {
        dynamicConfigOptions = {
          http = {
            services = {
              restic.loadBalancer.servers = [
                {
                  url = "http://localhost:8012";
                }
              ];
            };

            routers = {
              restic = {
                entryPoints = [ "websecure" ];
                rule = "Host(`restic.homelab.${inputs.nix-secrets.domain}`)";
                service = "restic";
              };
            };
          };
        };
      };

      prometheus = {
        exporters.restic = {
          enable = true;
          repository = "rest:http://127.0.0.1:8012";
          passwordFile = config.sops.secrets.restic_repository_password.path;
          environmentFile = config.sops.secrets.restic_environment.path;
          listenAddress = "127.0.0.1";
          port = 9753;
          refreshInterval = 86400; # every day
        };
        scrapeConfigs = [
          {
            job_name = "restic-exporter";
            static_configs = [
              {
                targets = [
                  "${config.services.prometheus.exporters.restic.listenAddress}:${toString config.services.prometheus.exporters.restic.port}"
                ];
              }
            ];
          }
        ];
      };
    };

    users.users.restic-exporter = {
      description = "restic exporter service user";
      createHome = false;
      isSystemUser = true;
      group = "restic-exporter";
    };
    users.groups.restic-exporter = { };

    sops.secrets = {
      restic_mount = {
        owner = config.users.users.restic.name;
        inherit (config.users.users.restic) group;
      };
      restic_repository_password = { };
      restic_environment = { };
    };

    systemd.services.restic-rest-server.unitConfig = {
      RequiresMountsFor = "/mnt/restic";
    };

    fileSystems = {
      "/mnt/restic" = {
        device = inputs.nix-secrets.restic.mountTarget;
        fsType = "cifs";
        options = [
          "credentials=${config.sops.secrets.restic_mount.path}"
          "uid=${toString config.users.users.restic.uid}"
          "gid=${toString config.users.groups.restic.gid}"
          "x-systemd.automount"
          "noauto"
          "x-systemd.idle-timeout=60"
          "x-systemd.mount-timeout=5s"
        ];
      };
    };
  };
}
