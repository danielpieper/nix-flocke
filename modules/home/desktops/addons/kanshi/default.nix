{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.desktops.addons.kanshi;
in
{
  options.desktops.addons.kanshi = {
    enable = mkEnableOption "Enable kanshi display addon";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kanshi
    ];

    services.kanshi = {
      enable = true;
      systemdTarget = "hyprland-session.target";
      settings = [
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "eDP-1";
            }
          ];
        }
        {
          profile.name = "docked-home-2";
          profile.outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
            }
            {
              criteria = "Samsung Electric Company U28E590 HTPH403281";
              position = "1920,0";
              mode = "3840x2160@60Hz";
              scale = 1.5;
            }
          ];
        }
        {
          profile.name = "docked-home-3";
          profile.outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
            }
            {
              criteria = "Samsung Electric Company U28E590 HTPH403281";
              position = "1920,0";
              mode = "3840x2160@60Hz";
              scale = 1.5;
            }
            {
              criteria = "LG Electronics 27GL850 007NTYT59834";
              position = "4480,0";
              mode = "2560x1440@59.95Hz";
            }
          ];
        }
        {
          profile.name = "ventx-docked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              # criteria = "Lenovo Group Limited 0x40A9";
              mode = "1920x1080@60Hz";
              position = "0,991";
            }
            {
              # criteria = "DP-1";
              criteria = "LG Electronics LG HDR WQHD 0x00005180";
              mode = "3840x1600@59.99Hz";
              position = "1920,471";
            }
            {
              # criteria = "HDMI-A-1";
              criteria = "Dell Inc. DELL U2715H GH85D67M14GL";
              mode = "2560x1440@59.95Hz";
              position = "5760,0";
              transform = "90";
            }
          ];
        }
      ];
    };
  };
}
