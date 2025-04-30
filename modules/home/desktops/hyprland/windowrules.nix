{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.desktops.hyprland;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      workspace = [
        # Smart Gaps
        "w[tv1]s[false], gapsout:0, gapsin:0" # w = window count, t = tiled-only, v = visible only, 1 = one visible, tiled window, ignore special workspace
        "f[1]s[false], gapsout:0, gapsin:0" # f = fullscreen, 1 = maximised
      ];
      windowrule = [
        # https://wiki.hyprland.org/Configuring/Window-Rules/

        # Smart Gaps
        "bordersize 0, floating:0, onworkspace:w[tv1]s[false]"
        "rounding 0, floating:0, onworkspace:w[tv1]s[false]"
        "bordersize 0, floating:0, onworkspace:f[1]s[false]"
        "rounding 0, floating:0, onworkspace:f[1]s[false]"

        "fullscreen, class:^(com.gabm.satty)$"

        "workspace 2 silent,class:^(firefox|google-chrome|zen)$"
        "workspace 4 silent,class:^(steam|lutris|com.moonlight_stream.Moonlight)$"
        "workspace 5 silent,class:^(discord|Slack|goofcord)$"

        # TODO: Does not work to float all windows on the special workspace:
        # "float, workspace:special"
        "float,class:^(Signal|signal|1Password)$"
        "workspace special,class:^(Signal|signal|1Password)$"

        "idleinhibit fullscreen, class:^(firefox|google-chrome|zen)$"

        "suppressevent fullscreen,class:^(firefox)$,title:^(Picture-in-Picture|Firefox)$"
        "float,class:^(firefox)$,title:^(Picture-in-Picture|Firefox)$"
        "pin,class:^(firefox)$,title:^(Picture-in-Picture|Firefox)$"
        "size 800 450,class:^(firefox)$,title:^(Picture-in-Picture|Firefox)$"
        "move 100%-800 100%-480,class:^(firefox)$,title:^(Picture-in-Picture|Firefox)$"
      ];
    };
  };
}
