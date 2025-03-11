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
      windowrulev2 = [
        "workspace 2 silent,class:^(firefox|google-chrome)$"
        "workspace 4 silent,class:^(steam|lutris|com.moonlight_stream.Moonlight)$"
        "workspace 5 silent,class:^(Signal|signal|discord|Slack|goofcord)$"

        "idleinhibit fullscreen, class:^(firefox|google-chrome)$"
        "stayfocused,class:^(1Password)$,title:^(Quick Access)"

        "suppressevent fullscreen,class:^(firefox)$,title:^(Picture-in-Picture|Firefox)$"
        "float,class:^(firefox)$,title:^(Picture-in-Picture|Firefox)$"
        "pin,class:^(firefox)$,title:^(Picture-in-Picture|Firefox)$"
        "size 800 450,class:^(firefox)$,title:^(Picture-in-Picture|Firefox)$"
        "move 100%-800 100%-480,class:^(firefox)$,title:^(Picture-in-Picture|Firefox)$"
      ];
    };
  };
}
