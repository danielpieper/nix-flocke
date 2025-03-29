{
  config,
  lib,
  inputs,
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
        devices = inputs.nix-secrets.syncthing.devices;
        folders = inputs.nix-secrets.syncthing.folders;
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
              rule = "Host(`syncthing-${hostname}.homelab.${inputs.nix-secrets.domain}`)";
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
