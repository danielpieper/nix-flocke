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
          lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock ";
        };

        listener = [
          {
            timeout = 60;
            on-timeout = "pgrep hyprlock && systemctl suspend";
          }
          {
            timeout = 5 * 60;
            on-timeout = "${pkgs.flocke.dim}/bin/dim --alpha 0.6 --duration 120 && loginctl lock-session";
          }
          {
            timeout = 8 * 60;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
