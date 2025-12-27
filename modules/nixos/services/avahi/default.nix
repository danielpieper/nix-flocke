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
      ipv4 = true;
      ipv6 = true;
      nssmdns4 = true;
      nssmdns6 = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };
  };
}
