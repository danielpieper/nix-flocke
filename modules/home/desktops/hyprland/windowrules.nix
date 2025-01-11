{
  config,
  lib,
  ...
}:
with lib;
let
  rule = rules: attrs: attrs // { inherit rules; };
  cfg = config.desktops.hyprland;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.windowRules =
      let
        firefoxVideo = {
          class = [ "firefox" ];
          title = [ "^(Picture-in-Picture|Firefox)$" ];
        };
        browsers = {
          class = [ "^(firefox|google-chrome)$" ];
        };
        chat = {
          class = [ "^(Signal|signal|discord|Slack|goofcord)$" ];
        };
        gaming = {
          class = [ "^(steam|lutris|moonlight)$" ];
        };
      in
      lib.concatLists [
        (map (rule [
          "idleinhibit fullscreen"
          "float"
          "pin"
          "size 800 450"
          "move 100%-800 100%-480"
        ]) [ firefoxVideo ])
        (map (rule [
          "workspace 2"
          "suppressevent fullscreen"
        ]) [ browsers ])
        (map (rule [ "workspace 5" ]) [ chat ])
        (map (rule [ "workspace 6" ]) [ gaming ])
      ];
  };
}
