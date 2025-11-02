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

    services.swayidle =
      let
        # Detect which compositor is active
        isHyprland = config.wayland.windowManager.hyprland.enable or false;
        isNiri = config.programs.niri.enable or false;

        # Set systemd target based on compositor
        systemdTarget =
          if isHyprland then
            "hyprland-session.target"
          else if isNiri then
            "niri.service"
          else
            "graphical-session.target";

        # DPMS commands vary by compositor
        dpmsOffCmd =
          if isHyprland then
            "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms off"
          else if isNiri then
            "${pkgs.wlopm}/bin/wlopm --off \\*"
          else
            "";

        dpmsOnCmd =
          if isHyprland then
            "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch dpms on"
          else if isNiri then
            "${pkgs.wlopm}/bin/wlopm --on \\*"
          else
            "";
      in
      {
        enable = true;
        inherit systemdTarget;
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
        ]
        ++ lib.optional (dpmsOffCmd != "") {
          timeout = 600;
          command = dpmsOffCmd;
          resumeCommand = dpmsOnCmd;
        };
      };
  };
}
