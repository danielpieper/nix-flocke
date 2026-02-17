{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.desktops.addons.swaylock;
in
{
  options.desktops.addons.swaylock = {
    enable = mkEnableOption "Enable swaylock lock management";
    blur = mkOpt (types.nullOr types.str) "7x5" "radius x times blur the image.";
    vignette = mkOpt (types.nullOr types.str) "0.5x0.5" "base:factor apply vignette effect.";
    binary =
      mkOpt (types.nullOr types.str) "${pkgs.swaylock-effects}/bin/swaylock"
        "Location of the binary to use for swaylock.";
  };

  config = mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        show-failed-attempts = true;
        screenshots = true;
        clock = true;

        # Clock formatting like hyprlock
        timestr = "%H:%M";
        datestr = "%A %d %B";

        indicator = true;
        indicator-radius = 350;
        indicator-thickness = 5;

        effect-blur = cfg.blur;
        effect-vignette = cfg.vignette;
        fade-in = 0.2;

        font = "Inter Variable";
        font-size = 120;
      };
    };

    services.swayidle = {
      enable = true;
      systemdTarget = "niri.service";
      events = [
        {
          event = "before-sleep";
          command = "${cfg.binary} -fF";
        }
        {
          event = "lock";
          command = "${cfg.binary} -fF";
        }
      ];
      timeouts = [
        {
          timeout = 610;
          command = "${pkgs.systemd}/bin/loginctl lock-session";
        }
        {
          timeout = 600;
          command = "${pkgs.wlopm}/bin/wlopm --off \\*";
          resumeCommand = "${pkgs.wlopm}/bin/wlopm --on \\*";
        }
      ];
    };
  };
}
