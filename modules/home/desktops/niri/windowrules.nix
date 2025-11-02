{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.desktops.niri;
in
{
  config = mkIf cfg.enable {
    programs.niri.settings = {
      window-rules = [
        # Satty (screenshot editor) - open fullscreen
        {
          matches = [ { app-id = "^com\\.gabm\\.satty$"; } ];
          open-fullscreen = true;
        }

        # Browser windows - workspace 2
        {
          matches = [
            { app-id = "^firefox$"; }
            { app-id = "^google-chrome$"; }
          ];
          open-on-workspace = "2";
        }

        # Gaming - workspace 4
        {
          matches = [
            { app-id = "^steam$"; }
            { app-id = "^lutris$"; }
            { app-id = "^com\\.moonlight_stream\\.Moonlight$"; }
            { app-id = "^chiaki$"; }
          ];
          open-on-workspace = "4";
        }

        # Communication apps - workspace 5
        {
          matches = [
            { app-id = "^discord$"; }
            { app-id = "^Slack$"; }
            { app-id = "^goofcord$"; }
          ];
          open-on-workspace = "5";
        }

        # Special workspace floating windows
        {
          matches = [
            { app-id = "^Signal$|^signal$"; }
            { app-id = "^1Password$"; }
            { app-id = "^\\.blueman-manager-wrapped$"; }
            { app-id = "^org\\.pulseaudio\\.pavucontrol$"; }
          ];
          open-floating = true;
        }

        # Firefox Picture-in-Picture
        {
          matches = [
            {
              app-id = "^firefox$";
              title = "^(Picture-in-Picture|Firefox)$";
            }
          ];
          open-floating = true;
          default-column-width = {
            fixed = 800;
          };
        }
      ];
    };
  };
}
