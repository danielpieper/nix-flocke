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
in
{
  options.services.flocke.syncthing = {
    enable = mkEnableOption "Enable syncthing";

    user = mkOption {
      type = types.str;
      default = username;
      description = "User to run Syncthing as";
    };

    group = mkOption {
      type = types.str;
      default = group;
      description = "Group to run Syncthing as";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/home/${username}";
      description = "Directory for Syncthing data";
    };
  };

  config = mkIf cfg.enable {
    services = {
      syncthing = {
        enable = true;
        inherit (cfg) user group dataDir;
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
