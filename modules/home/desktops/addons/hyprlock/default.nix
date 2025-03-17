{
  config,
  lib,
  ...
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
        };
        background = {
          path = lib.mkForce "screenshot";
          blur_passes = 2;
          blur_size = 4;
          noise = 0.011700;
        };
        label = [
          {
            text = "$TIME";
            color = "$text";
            font_size = 90;
            font_family = "$font";
            position = "-30, 0";
            halign = "right";
            valign = "top";
          }
          {
            text = "cmd[update:43200000] date +\"%A, %d %B %Y\"";
            color = "$text";
            font_size = 25;
            font_family = "$font";
            position = "-30, -150";
            halign = "right";
            valign = "top";
          }
        ];
      };
    };
  };
}
