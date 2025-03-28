{ config
, lib
, ...
}:
with lib;
let
  cfg = config.desktops.addons.wlsunset;
in
{
  options.desktops.addons.wlsunset = {
    enable = mkEnableOption "Enable wlsunset night light";
  };

  config = mkIf cfg.enable {
    services.wlsunset = {
      enable = true;
      latitude = "47.9";
      longitude = "12.7";
    };
  };
}
