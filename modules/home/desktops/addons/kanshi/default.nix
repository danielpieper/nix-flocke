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
      package = pkgs.kanshi;
      systemdTarget = "";
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
          profile.name = "home_office_laptop_docked";
          profile.outputs = [
            {
              criteria = "GIGA-BYTE TECHNOLOGY CO. LTD. Gigabyte M32U  (DP-5 via HDMI)";
              position = "3840,0";
              mode = "3840x2160@144Hz";
            }
            {
              criteria = "Dell Inc. DELL G3223Q 82X70P3 (DP-4)";
              position = "0,0";
              mode = "3840x2160@60Hz";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        }
        {
          profile.name = "home_office";
          profile.outputs = [
            {
              criteria = "GIGA-BYTE TECHNOLOGY CO. LTD. Gigabyte M32U  (DP-5 via HDMI)";
              position = "3840,0";
              mode = "3840x2160@144Hz";
            }
            {
              criteria = "Dell Inc. DELL G3223Q 82X70P3 (DP-4)";
              position = "0,0";
              mode = "3840x2160@60Hz";
            }
          ];
        }
        {
          profile.name = "desktop";
          profile.outputs = [
            {
              criteria = "GIGA-BYTE TECHNOLOGY CO., LTD. Gigabyte M32U 21351B000087";
              position = "3840,0";
              mode = "3840x2160@144Hz";
            }
            {
              criteria = "Dell Inc. DELL G3223Q 82X70P3";
              position = "0,0";
              mode = "3840x2160@60Hz";
            }
          ];
        }
      ];
    };
  };
}
