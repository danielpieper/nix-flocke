{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.gotify;
in
{
  options.services.flocke.gotify = {
    enable = mkEnableOption "Enable the notify service";
  };

  config = mkIf cfg.enable {
    services = {
      gotify = {
        enable = true;
        environment = {
          GOTIFY_SERVER_PORT = "8051";
        };
      };

      caddy.virtualHosts."gotify.${inputs.nix-secrets.homelabDomain}" = {
        useACMEHost = inputs.nix-secrets.homelabDomain;
        extraConfig = "reverse_proxy localhost:8051";
      };
    };
  };
}
