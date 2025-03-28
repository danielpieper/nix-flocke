{ config
, lib
, ...
}:
with lib;
with lib.flocke;
let
  cfg = config.desktops.addons.wluma;
in
{
  options.desktops.addons.wluma = with types; {
    enable = mkBoolOpt false "Whether to enable the wluma";
  };

  config = mkIf cfg.enable {
    services.wluma = {
      enable = true;
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };
      settings = {
        # als.iio = {
        #   path = "/sys/bus/iio/devices";
        #   thresholds = {
        #     "0" = "night";
        #     "20" = "dark";
        #     "80" = "dim";
        #     "250" = "normal";
        #     "500" = "bright";
        #     "800" = "outdoors";
        #   };
        # };
        als.webcam = {
          video = 0;
          thresholds = {
            "0" = "night";
            "15" = "dark";
            "30" = "dim";
            "45" = "normal";
            "60" = "bright";
            "75" = "outdoors";
          };
        };
        output.backlight = [
          {
            name = "eDP-1";
            path = "/sys/class/backlight/intel_backlight";
            capturer = "wayland";
          }
        ];
        keyboard = [
          {
            name = "keyboard-thinkpad";
            path = "/sys/bus/platform/devices/thinkpad_acpi/leds/tpacpi::kbd_backlight";
          }
        ];
      };
    };
  };
}
