{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.desktops.addons.waybar;
in
{
  options.desktops.addons.waybar = {
    enable = mkEnableOption "Enable waybar";
  };

  config = mkIf cfg.enable {
    stylix.targets.waybar.addCss = false;
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
            active-only = false;
            all-outputs = true;
            move-to-monitor = true;
            format = "{windows}<sub>{name}</sub>";
            window-rewrite-default = "󰣆 ";
            window-rewrite = {
              "class<google-chrome>" = " ";
              "class<firefox>" = " ";
              "class<Tor Browser>" = " ";
              "class<(firefox|google-chrome)> title<.*\\bSlack\\b.*>" = " ";
              "class<(firefox|google-chrome)> title<Spotify\\b.*>" = " ";
              "class<(firefox|google-chrome)> title<YouTube\\b.*>" = " ";
              "class<(firefox|google-chrome)> title<.*\\bMail\\b.*>" = "󰊫 ";
              "class<(firefox|google-chrome)> title<.*\\bCalendar\\b.*>" = "󰃰 ";
              "class<(firefox|google-chrome)> title<.*\\bForgejo\\b.*>" = " ";
              "class<(firefox|google-chrome)> title<.*\\bGitLab\\b.*>" = " ";

              "class<com.mitchellh.ghostty>" = " ";
              "class<com.mitchellh.ghostty> title<Zellij\\b.*>" = " ";

              "class<(steam|lutris|com.moonlight_stream.Moonlight)>" = " ";
              "class<(signal|goofcord)>" = " ";
              "class<1Password>" = " ";
            };
            format-icons = {
              urgent = "  ";
              focused = "  ";
              default = "  ";
            };
            on-click = "activate";
          };
          clock = {
            format = "󰃰 {:%d.%m  %H:%M}";
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
              notification = "󱅫 ";
              none = " ";
              "dnd-notification" = " ";
              "dnd-none" = "󰂛 ";
              "inhibited-notification" = " ";
              "inhibited-none" = " ";
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
            icon-size = 18;
            spacing = 8;
          };
          systemd-failed-units = {
            hide-on-ok = true;
            format = "{nr_failed} 󰚌 ";
          };
        }
      ];

      style = builtins.readFile ./styles.css;
    };
  };
}
