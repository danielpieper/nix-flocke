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
  inherit (config.users.users.${username}) group;
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
      inherit group;
      dataDir = homedir;
      overrideDevices = false; # overrides any devices added or deleted through the WebUI
      overrideFolders = false; # overrides any folders added or deleted through the WebUI
      openDefaultPorts = true; # 21027/tcp & 22000
      settings = {
        inherit (inputs.nix-secrets.syncthing) devices folders;
        gui.insecureSkipHostcheck = true; # required for traefik
      };
    };

    services.traefik = {
      dynamic.files."syncthing".settings = {
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
              middlewares = [ "authentik" ];
            };
          };
        };
      };
    };
  };
}
