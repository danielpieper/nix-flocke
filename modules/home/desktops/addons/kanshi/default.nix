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
          profile.name = "docked";
          profile.outputs = [
            {
              criteria = "eDP-1";
              position = "0,0";
              mode = "1920x1200@60Hz";
            }
            {
              criteria = "Samsung Electric Company U28E590 HTPH403281";
              position = "1920,0";
              mode = "2560x1440@60Hz";
              # mode = "3840x2160@60Hz";
              # scale = 1.5;
            }
          ];
        }
      ];
    };
  };
}
