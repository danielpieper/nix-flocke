{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.desktops.addons.hypridle;
  wifi-lock = pkgs.writeShellScriptBin "wifi-lock" ''
    #!/usr/bin/env bash

    TRUSTED_WIFI="404 Network unavailable"
    CURRENT_WIFI=$(${pkgs.networkmanager}/bin/nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d':' -f2)

    if [ "$CURRENT_WIFI" != "$TRUSTED_WIFI" ]; then
      loginctl lock-session
    fi
  '';
in
{
  options.desktops.addons.hypridle = with types; {
    enable = mkBoolOpt false "Whether to enable the hypridle";
  };

  config = mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "${wifi-lock}/bin/wifi-lock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          lock_cmd = "pidof hyprlock || hyprlock ";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "${wifi-lock}/bin/wifi-lock";
          }
          {
            timeout = 330;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
