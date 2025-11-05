{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.desktops.niri;

  toggleTouchpad = pkgs.writeShellScriptBin "toggleTouchpad" ''
    #!/usr/bin/env sh

    # Set device to be toggled:
    # TODO: this needs per-device config
    DEVICE_NAME="uniw0001:00-093a:0255-touchpad" # tars touchpad

    if [ -z "$XDG_RUNTIME_DIR" ]; then
      export XDG_RUNTIME_DIR=/run/user/$(id -u)
    fi

    export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

    enable_touchpad() {
        printf "true" >"$STATUS_FILE"
      notify-send -u normal "Enabling Touchpad"
    # TODO: Need to find niri equivalent for touchpad toggle
    }

    disable_touchpad() {
        printf "false" >"$STATUS_FILE"
    notify-send -u normal "Disabling Touchpad"
    # TODO: Need to find niri equivalent for touchpad toggle
    }

    if ! [ -f "$STATUS_FILE" ]; then
      enable_touchpad
    else
      if [ $(cat "$STATUS_FILE") = "true" ]; then
        disable_touchpad
      elif [ $(cat "$STATUS_FILE") = "false" ]; then
        enable_touchpad
      fi
    fi
  '';
in
{
  config = mkIf cfg.enable {
    programs.niri.settings.binds = with config.lib.niri.actions; {
      # Window management
      "Mod+Return".action.spawn = [
        "uwsm"
        "app"
        "--"
        "wezterm"
        "start"
        "--always-new-process"
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

      "Mod+Space".action.spawn = [
        "${config.desktops.addons.rofi.package}/bin/rofi"
        "-show"
        "drun"
        "-mode"
        "drun"
        "-run-command"
        "uwsm app -- {cmd}"
      ];

      # Lock Screen
      "XF86Launch5".action.spawn = [ "${pkgs.swaylock-effects}/bin/swaylock" ];
      "XF86Launch4".action.spawn = [ "${pkgs.swaylock-effects}/bin/swaylock" ];
      "Mod+BackSpace".action.spawn = [ "${pkgs.swaylock-effects}/bin/swaylock" ];
      "Mod+Ctrl+BackSpace".action.spawn = [
        "wlogout"
        "--column-spacing"
        "50"
        "--row-spacing"
        "50"
      ];

      # Touchpad toggle
      "XF86TouchpadToggle".action.spawn = [ "${toggleTouchpad}/bin/toggleTouchpad" ];

      # Screenshots
      "Print".action.spawn = [
        "${pkgs.grimblast}/bin/grimblast"
        "save"
        "area"
        "-"
      ];
      "Shift+Print".action.spawn = [
        "${pkgs.grimblast}/bin/grimblast"
        "save"
        "active"
        "-"
      ];
      "Ctrl+Print".action.spawn = [
        "${pkgs.grimblast}/bin/grimblast"
        "save"
        "screen"
        "-"
      ];

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

      # Media keys
      "XF86MonBrightnessUp".action.spawn = [
        "${pkgs.brightnessctl}/bin/brightnessctl"
        "-q"
        "s"
        "+10%"
      ];
      "XF86MonBrightnessDown".action.spawn = [
        "${pkgs.brightnessctl}/bin/brightnessctl"
        "-q"
        "s"
        "10%-"
      ];
      "XF86AudioRaiseVolume".action.spawn = [
        "${pkgs.pamixer}/bin/pamixer"
        "-i"
        "5"
      ];
      "XF86AudioLowerVolume".action.spawn = [
        "${pkgs.pamixer}/bin/pamixer"
        "-d"
        "5"
      ];
      "XF86AudioMute".action.spawn = [
        "${pkgs.pamixer}/bin/pamixer"
        "--toggle-mute"
      ];
      "XF86AudioMicMute".action.spawn = [
        "${pkgs.pamixer}/bin/pamixer"
        "--default-source"
        "--toggle-mute"
      ];
      "XF86AudioNext".action.spawn = [
        "playerctl"
        "next"
      ];
      "XF86AudioPrev".action.spawn = [
        "playerctl"
        "previous"
      ];
      "XF86AudioPlay".action.spawn = [
        "playerctl"
        "play-pause"
      ];
      "XF86AudioStop".action.spawn = [
        "playerctl"
        "stop"
      ];
    };
  };
}
