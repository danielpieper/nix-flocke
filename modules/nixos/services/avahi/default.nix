{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.services.flocke.avahi;
in
{
  options.services.flocke.avahi = {
    enable = mkEnableOption "Enable The avahi service";
  };

  config = mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      settings = {
        server = {
          use-ipv4 = true;
          use-ipv6 = true;
        };
        publish = {
          disable-publishing = false;
          disable-user-service-publishing = false;
          publish-addresses = true;
        };
      };
    };
  };
}
