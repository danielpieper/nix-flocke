{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.desktops.addons.waybar;
  touchpadToggle = pkgs.writeShellScriptBin "touchpad-toggle" ''
    set -euo pipefail
    HYPRLAND_DEVICE="syna8008:00-06cb:ce58-touchpad"

    if [ -z "$XDG_RUNTIME_DIR" ]; then
      export XDG_RUNTIME_DIR=/run/user/$(id -u)
    fi

    export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

    enable_touchpad() {
      printf "true" > "$STATUS_FILE"
      # notify-send -u normal "Enabling Touchpad"
      hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" true
    }

    disable_touchpad() {
      printf "false" > "$STATUS_FILE"
      # notify-send -u normal "Disabling Touchpad"
      hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" false
    }

    if ! [ -f "$STATUS_FILE" ]; then
      disable_touchpad
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
  options.desktops.addons.waybar = {
    enable = mkEnableOption "Enable waybar";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.hyprpanel
      pkgs.ags
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          margin = "0 0 0 0";
          modules-left = [
            "hyprland/workspaces"
            "tray"
          ];
          modules-center = [
            "custom/notification"
            "systemd-failed-units"
            "clock"
            "idle_inhibitor"
            "custom/touchpad"
            "hyprland/language"
          ];
          modules-right = [
            "backlight"
            "backlight/slider"
            "pulseaudio"
            "pulseaudio/slider"
            "network"
            "battery"
          ];
          "hyprland/workspaces" = {
            format = "{icon}";
            sort-by-number = true;
            active-only = false;
            format-icons = {
              "1" = "  ";
              "2" = "  ";
              "3" = "  ";
              "4" = "  ";
              "5" = "  ";
              "6" = "  ";
              urgent = "  ";
              focused = "  ";
              default = "  ";
            };
            on-click = "activate";
          };
          clock = {
            format = "󰃰 {:%d.%m %H:%M}";
            interval = 1;
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "year";
              "mode-mon-col" = 3;
              "weeks-pos" = "right";
              "on-scroll" = 1;
              "on-click-right" = "mode";
              format = {
                months = "<span color='#cba6f7'><b>{}</b></span>";
                days = "<span color='#b4befe'><b>{}</b></span>";
                weeks = "<span color='#89dceb'><b>W{}</b></span>";
                weekdays = "<span color='#f2cdcd'><b>{}</b></span>";
                today = "<span color='#f38ba8'><b><u>{}</u></b></span>";
              };
            };
          };
          "custom/notification" = {
            tooltip = false;
            format = "{} {icon}";
            "format-icons" = {
              notification = "󱅫";
              none = "";
              "dnd-notification" = " ";
              "dnd-none" = "󰂛";
              "inhibited-notification" = " ";
              "inhibited-none" = "";
              "dnd-inhibited-notification" = " ";
              "dnd-inhibited-none" = " ";
            };
            "return-type" = "json";
            "exec-if" = "which swaync-client";
            exec = "swaync-client -swb";
            "on-click" = "sleep 0.1 && swaync-client -t -sw";
            "on-click-right" = "sleep 0.1 && swaync-client -d -sw";
            escape = true;
          };
          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = "󰒳";
              deactivated = "󰒲";
            };
          };
          backlight = {
            format = "{icon}";
            format-icons = [
              "󱩎 "
              "󱩏 "
              "󱩐 "
              "󱩑 "
              "󱩒 "
              "󱩓 "
              "󱩔 "
              "󱩕 "
              "󱩖 "
              "󰛨 "
            ];
          };
          "backlight/slider" = {
            min = 0;
            max = 100;
            orientation = "horizontal";
          };
          battery = {
            interval = 5;
            states = {
              good = 60;
              warning = 30;
              critical = 15;
            };
            format = "{power}W {icon}{capacity}%";
            format-alt = "{power}W {icon}{time}";
            format-charging = " {capacity}%";
            format-icons = [
              "󰁻 "
              "󰁽 "
              "󰁿 "
              "󰂁 "
              "󰂂 "
            ];
          };
          network = {
            interval = 1;
            format-wifi = " {essid}";
            format-ethernet = " 󰈀 ";
            format-disconnected = " 󱚵  ";
            tooltip-format = ''
              {ifname}
              {ipaddr}/{cidr}
              {signalStrength}
              {frequency} Ghz
              Up: {bandwidthUpBits}
              Down: {bandwidthDownBits}
            '';
          };
          pulseaudio = {
            scroll-step = 2;
            format = "{icon}";
            format-muted = "  ";
            format-icons = {
              headphone = "  ";
              headset = "  ";
              default = [
                "  "
                "  "
              ];
            };
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };
          "pulseaudio/slider" = {
            min = 0;
            max = 100;
            orientation = "horizontal";
          };
          tray = {
            icon-size = 16;
            spacing = 8;
          };
          "hyprland/language" = {
            "format-en" = "en";
            "format-de" = "de";
          };
          systemd-failed-units = {
            hide-on-ok = true;
            format = "{nr_failed} 󰚌 ";
          };
          "custom/touchpad" = {
            format = "󰟸 ";
            on-click = "${touchpadToggle}/bin/touchpad-toggle";
          };
        }
      ];

      style = builtins.readFile ./styles.css;
    };
  };
}
