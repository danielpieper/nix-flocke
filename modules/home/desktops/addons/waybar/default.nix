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
            "cpu"
            "backlight"
            "pulseaudio"
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
              "class<zen>" = " ";
              "class<Tor Browser>" = " ";
              "class<(zen|firefox|google-chrome)> title<.*\\bSlack\\b.*>" = " ";
              "class<(zen|firefox|google-chrome)> title<Spotify\\b.*>" = " ";
              "class<(zen|firefox|google-chrome)> title<YouTube\\b.*>" = " ";
              "class<(zen|firefox|google-chrome)> title<.*\\bMail\\b.*>" = "󰊫 ";
              "class<(zen|firefox|google-chrome)> title<.*\\bCalendar\\b.*>" = "󰃰 ";
              "class<(zen|firefox|google-chrome)> title<.*\\bForgejo\\b.*>" = " ";
              "class<(zen|firefox|google-chrome)> title<.*\\bGitLab\\b.*>" = " ";

              "class<com.mitchellh.ghostty|org.wezfurlong.wezterm>" = " ";
              "class<com.mitchellh.ghostty> title<Zellij\\b.*>" = " ";

              "class<(steam|lutris|com.moonlight_stream.Moonlight)>" = " ";
              "class<(signal|goofcord)>" = " ";
              "class<1Password>" = " ";
              "class<Slack>" = " ";
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
            format = "{icon}{percent}%";
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
          battery = {
            interval = 5;
            states = {
              good = 60;
              warning = 30;
              critical = 15;
            };
            format-discharging = "{icon}{capacity}% <small>{time} {power}W</small>";
            format-plugged = " {capacity}%";
            format-charging = " {capacity}% <small>{time} {power}W</small>";
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
            format = "{icon}{volume}%";
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
          tray = {
            icon-size = 18;
            spacing = 8;
          };
          systemd-failed-units = {
            hide-on-ok = true;
            format = "{nr_failed} 󰚌 ";
          };
          cpu = {
            interval = 2;
            format = "{icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}";
            format-icons = with config.lib.stylix.colors.withHashtag; [
              "<span color='${base03}'>▁</span>" # white
              "<span color='${base04}'>▂</span>" # white
              "<span color='${base0D}'>▃</span>" # blue
              "<span color='${base0B}'>▄</span>" # green
              "<span color='${base0A}'>▅</span>" # yellow
              "<span color='${base0A}'>▆</span>" # yellow
              "<span color='${base09}'>▇</span>" # orange
              "<span color='${base08}'>█</span>" # red
            ];
          };
        }
      ];

      style = builtins.readFile ./styles.css;
    };
  };
}
