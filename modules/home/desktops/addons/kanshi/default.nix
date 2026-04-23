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
    enable = mkEnableOption "Enable kanshi display addon (similar to autorandr)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kanshi
    ];

    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";
      settings = [
        {
          profile.name = "undocked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
              mode = "2560x1600@240.00Hz";
              scale = 1.25;
            }
          ];
        }
        {
          profile.name = "docked-home-2";
          profile.outputs = [
            {
              criteria = "LG Electronics 27GL850 007NTYT59834";
              position = "0,0";
              mode = "2560x1440@144Hz";
            }
            {
              criteria = "eDP-1";
              position = "2560,0";
              mode = "2560x1600@240.00Hz";
              scale = 1.25;
            }
          ];
        }
        {
          profile.name = "docked-home-2-wide";
          profile.outputs = [
            {
              criteria = "LG Electronics LG HDR WQHD+ 201NTHMLG281";
              position = "0,0";
              mode = "3840x1600@75Hz";
            }
            {
              criteria = "eDP-1";
              position = "3840,0";
              mode = "2560x1600@240.00Hz";
              scale = 1.25;
            }
          ];
        }
        {
          profile.name = "docked-home-3";
          profile.outputs = [
            {
              criteria = "LG Electronics LG HDR WQHD+ 201NTHMLG281";
              position = "0,0";
              mode = "3840x1600@75Hz";
            }
            {
              criteria = "LG Electronics 27GL850 007NTYT59834";
              position = "3840,0";
              mode = "2560x1440@144Hz";
            }
            {
              criteria = "eDP-1";
              position = "6400,0";
              mode = "2560x1600@240.00Hz";
              scale = 1.25;
            }
          ];
        }
        {
          profile.name = "docked-home-tv";
          profile.outputs = [
            {
              criteria = "eDP-1";
              position = "0,80";
              mode = "2560x1600@240.00Hz";
              scale = 1.25;
            }
            {
              criteria = "LG Electronics LG TV SSCR2 0x01010101";
              position = "2048,0";
              mode = "2560x1440@119.998Hz";
            }
          ];
        }
        {
          profile.name = "ventx-docked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              position = "0,991";
              mode = "2560x1600@240.00Hz";
              scale = 1.25;
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
