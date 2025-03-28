{ config
, lib
, ...
}:
with lib;
with lib.flocke;
let
  cfg = config.desktops.addons.hyprlock;
in
{
  options.desktops.addons.hyprlock = with types; {
    enable = mkBoolOpt false "Whether to enable the hyprlock";
  };

  config = mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          grace = 2;
          hide_cursor = true;
          ignore_empty_input = true;
          text_trim = true;
        };
        auth."fingerprint:enabled" = true;
        background = {
          path = lib.mkForce "screenshot";
          blur_passes = 2;
          contrast = 0.8916;
          brightness = 0.7172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0;
        };
        label = [
          {
            text = "cmd[update:1000] date +\"%H\"";
            color = "rgba(255, 255, 255, 1)";
            shadow_pass = 2;
            shadow_size = 3;
            shadow_color = "rgb(0,0,0)";
            shadow_boost = 1.2;
            font_size = 150;
            font_family = "Inter ExtraBold";
            position = "0, -250";
            halign = "center";
            valign = "top";
          }
          {
            text = "cmd[update:1000] date +\"%M\"";
            color = "rgba(255, 255, 255, 1)";
            font_size = 150;
            font_family = "Inter ExtraBold";
            position = "0, -420";
            halign = "center";
            valign = "top";
          }
          {
            text = "cmd[update:1000] date +\"%A %d %B\"";
            color = "rgba(255, 255, 255, 1)";
            font_size = 14;
            font_family = "Inter ExtraBold";
            position = "0, -640";
            halign = "center";
            valign = "top";
          }
        ];
        input-field = {
          size = "250, 60";
          outline_thickness = 0;
          dots_size = 0.1; # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.8; # Scale of dots' absolute size, 0.0 - 1.0
          dots_center = true;
          fade_on_empty = false;
          font_family = "Inter";
          placeholder_text = "<span foreground=\"##cdd6f4\">  $USER</span>";
          hide_input = false;
          position = "0, -470";
          halign = "center";
          valign = "center";
          zindex = 10;
        };
      };
    };
  };
}
