{
  config,
  lib,
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
        prometheus = true;
        dataDir = "/mnt/nas/restic";
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
                rule = "Host(`restic.homelab.daniel-pieper.com`)";
                service = "restic";
                tls.certResolver = "letsencrypt";
              };
            };
          };
        };
      };

      prometheus = {
        scrapeConfigs = [
          {
            job_name = "restic";
            basic_auth = {
              username = "restic";
              password_file = config.sops.secrets.restic_user_password.path;
            };
            static_configs = [
              { targets = [ config.services.restic.server.listenAddress ]; }
            ];
          }
        ];
      };
    };

    sops.secrets = {
      restic_mount = {
        sopsFile = ../secrets.yaml;
        owner = config.users.users.restic.name;
        group = config.users.users.restic.group;
      };
      restic_user_password = {
        sopsFile = ../secrets.yaml;
        owner = config.users.users.prometheus.name;
        group = config.users.users.prometheus.group;
      };
    };

    fileSystems = {
      "/mnt/nas/restic" = {
        device = "//192.168.178.38/restic";
        fsType = "cifs";
        options = [
          "credentials=${config.sops.secrets.restic_mount.path}"
          "uid=${toString config.users.users.restic.uid}"
          "gid=${toString config.users.groups.restic.gid}"
          "x-systemd.automount"
          "noauto"
          "x-systemd.idle-timeout=60"
          "x-systemd.device-timeout=5s"
          "x-systemd.mount-timeout=5s"
        ];
      };
    };
  };
}
