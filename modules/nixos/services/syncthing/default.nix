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
in
{
  options.services.flocke.syncthing = {
    enable = mkEnableOption "Enable syncthing";
  };

  config = mkIf cfg.enable {
    services = {
      syncthing = {
        enable = true;
        user = username;
        inherit group;
        dataDir = homedir;
        overrideDevices = false;
        overrideFolders = false;
        openDefaultPorts = true;
        settings.gui.insecureSkipHostcheck = true;
      };

      caddy.virtualHosts."syncthing.${inputs.nix-secrets.homelabDomain}" = {
        useACMEHost = inputs.nix-secrets.homelabDomain;
        extraConfig = "reverse_proxy localhost:8384";
      };
    };
  };
}
