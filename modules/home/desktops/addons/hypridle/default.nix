{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.desktops.addons.hypridle;
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
          before_sleep_cmd = "${pkgs.playerctl}/bin/playerctl pause -i kdeconnect; loginctl lock-session";
          # after_sleep_cmd = "hyprctl dispatch dpms on";
          lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock ";
        };

        listener = [
          {
            timeout = 45;
            on-timeout = "pgrep hyprlock && systemctl suspend";
          }
          {
            timeout = 435;
            on-timeout = "${pkgs.flocke.dim}/bin/dim --alpha 0.7 && loginctl lock-session";
          }
          # {
          #   timeout = 330;
          #   on-timeout = "hyprctl dispatch dpms off";
          #   on-resume = "hyprctl dispatch dpms on";
          # }
          {
            timeout = 480;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
