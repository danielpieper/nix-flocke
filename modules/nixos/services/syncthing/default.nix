{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.syncthing;
  username = config.user.name;
  group = config.users.users.${username}.group;
  homedir = "/home/${username}";
  hostname = config.networking.hostName;
in
{
  options.services.flocke.syncthing = {
    enable = mkEnableOption "Enable syncthing";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = username;
      group = group;
      dataDir = homedir;
      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI
      openDefaultPorts = true; # 21027/tcp & 22000
      settings = {
        gui.insecureSkipHostcheck = true; # required for traefik
        devices = {
          "oneplus8" = {
            id = "QBX6XQ5-JDZZ2Q7-CRCEVWJ-Y5J57UW-HAJZ5XB-KZJEHWJ-CNHATJM-X47T6QC";
          };
          "zorg" = {
            id = "DJAQ4CF-BHAFAXA-C5SGC6U-V63BVL3-SYOEQT3-OEJZNT5-3PC2MEJ-S3M2BQP";
          };
          "tars" = {
            id = "GNK5RN7-2DGYLB6-ELP4TEF-Y54EQNF-RTTJPRH-4OTD4ZH-E7GQJPR-M7GNNQE";
          };
          "hal" = {
            id = "3ULRQDX-V6MOMOM-PJKWDLI-TLAGBUZ-LJVB4G7-OZHUGD7-R4EAVYI-7VF2TQV";
          };
        };
        folders = {
          "Documents" = {
            path = "~/Documents"; # Which folder to add to Syncthing
            devices = [
              "oneplus8"
              "zorg"
              "tars"
              "hal"
            ]; # Which devices to share the folder with
            # ignorePerms = false; # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
          };
        };
      };
    };

    services.traefik = {
      dynamicConfigOptions = {
        http = {
          services = {
            syncthing.loadBalancer.servers = [
              {
                url = "http://localhost:8384";
              }
            ];
          };

          routers = {
            syncthing = {
              entryPoints = [ "websecure" ];
              rule = "Host(`syncthing-${hostname}.homelab.daniel-pieper.com`)";
              service = "syncthing";
              tls.certResolver = "letsencrypt";
              middlewares = [ "authentik" ];
            };
          };
        };
      };
    };
  };
}
