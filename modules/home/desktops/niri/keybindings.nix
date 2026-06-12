{
  pkgs,
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
    programs.niri.settings.binds =
      with config.lib.niri.actions;
      let
        noctalia =
          cmd:
          [
            "noctalia"
            "msg"
          ]
          ++ (pkgs.lib.splitString " " cmd);
      in
      {
        # Window management
        "Mod+Return".action.spawn = [
          "uwsm"
          "app"
          "--"
          "ghostty"
        ];
        "Mod+Up".action = toggle-overview;
        "Mod+Down".action = toggle-overview;
        "Mod+F1".action = show-hotkey-overlay;
        "Mod+Q".action = close-window;
        "Mod+F".action = maximize-column;
        # "Mod+F".action = maximize-window-to-edges;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+R".action = switch-preset-column-width;
        "Mod+B".action = toggle-window-floating;

        "Mod+Space".action.spawn = noctalia "panel-toggle launcher";
        "Mod+Comma".action.spawn = noctalia "settings-toggle";

        # Lock Screen
        "XF86Launch5".action.spawn = noctalia "session lock";
        "XF86Launch4".action.spawn = noctalia "session lock";
        "Mod+BackSpace".action.spawn = noctalia "session lock";
        "Mod+Ctrl+BackSpace".action.spawn = noctalia "panel-toggle session";

        # Screenshots
        "Print".action.screenshot = [ ];
        "Shift+Print".action.screenshot-window = [ ];
        "Ctrl+Print".action.screenshot-screen = [ ];

        # Focus movement
        "Mod+H".action = focus-column-left;
        "Mod+L".action = focus-column-right;
        "Mod+K".action = focus-window-up;
        "Mod+J".action = focus-window-down;

        # Workspace switching
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+0".action.focus-workspace = 10;

        # Move to workspace
        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;
        "Mod+Shift+6".action.move-column-to-workspace = 6;
        "Mod+Shift+7".action.move-column-to-workspace = 7;
        "Mod+Shift+8".action.move-column-to-workspace = 8;
        "Mod+Shift+9".action.move-column-to-workspace = 9;
        "Mod+Shift+0".action.move-column-to-workspace = 10;

        # Move workspace to monitor
        "Mod+Ctrl+H".action = move-workspace-to-monitor-left;
        "Mod+Ctrl+L".action = move-workspace-to-monitor-right;
        "Mod+Ctrl+K".action = move-workspace-to-monitor-up;
        "Mod+Ctrl+J".action = move-workspace-to-monitor-down;

        # Swap windows
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+L".action = move-column-right;
        "Mod+Shift+K".action = move-window-up;
        "Mod+Shift+J".action = move-window-down;

        # Resize
        "Mod+Alt+H".action.set-column-width = "-10%";
        "Mod+Alt+L".action.set-column-width = "+10%";
        "Mod+Alt+K".action.set-window-height = "-10%";
        "Mod+Alt+J".action.set-window-height = "+10%";

        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action = focus-workspace-down;
        };
        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action = focus-workspace-up;
        };
        "Mod+WheelScrollRight".action = focus-column-right;
        "Mod+WheelScrollLeft".action = focus-column-left;
        "Mod+Shift+WheelScrollDown".action = focus-column-right;
        "Mod+Shift+WheelScrollUp".action = focus-column-left;

        # Media keys
        "XF86MonBrightnessUp".action.spawn = noctalia "brightness-up";
        "XF86MonBrightnessDown".action.spawn = noctalia "brightness-down";
        "XF86AudioRaiseVolume".action.spawn = noctalia "volume-up";
        "XF86AudioLowerVolume".action.spawn = noctalia "volume-down";
        "XF86AudioMute".action.spawn = noctalia "volume-mute";
        "XF86AudioMicMute".action.spawn = noctalia "mic-mute";
        "XF86AudioNext".action.spawn = noctalia "media next";
        "XF86AudioPrev".action.spawn = noctalia "media previous";
        "XF86AudioPlay".action.spawn = noctalia "media toggle";
        "XF86AudioStop".action.spawn = noctalia "media stop";
      };
  };
}
