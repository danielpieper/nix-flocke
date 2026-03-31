{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.filebrowser;
  domain = inputs.nix-secrets.homelabDomain;
in
{
  options.services.flocke.filebrowser = {
    enable = mkEnableOption "Enable Filebrowser";
  };

  config = mkIf cfg.enable {
    services = {
      filebrowser = {
        enable = true;
        settings = {
          address = "127.0.0.1";
          port = 8085;
          root = "/var/lib/filebrowser/data";
        };
      };

      caddy.virtualHosts."files.${domain}" = {
        useACMEHost = domain;
        extraConfig = "reverse_proxy 127.0.0.1:8085";
      };
    };
  };
}
