{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.desktops.addons.noctalia;
in
{
  options.desktops.addons.noctalia = {
    enable = mkEnableOption "Enable noctalia";
  };

  imports = [
    inputs.noctalia.homeModules.default
  ];

  # noctalia 5.0.0 is a from-scratch native Wayland shell. `settings` is
  # serialised verbatim to ~/.config/noctalia/config.toml against the v5 schema
  # (https://docs.noctalia.dev/v5). Sounds play via PipeWire (bundled dr_wav) —
  # no GStreamer plumbing is required. Most settings hot-reload via inotify and
  # can also be tweaked at runtime in the Settings panel.
  config = mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      # Niri spawns noctalia at startup (see niri/config.nix), so the user
      # service stays off to avoid double instances.
      systemd.enable = false;

      settings = {
        shell = {
          ui_scale = 1.0;
          corner_radius_scale = 1.0;
          lang = "de";
          avatar_path = "/home/daniel/Pictures/me.jpg";
          telemetry_enabled = false;
          clipboard_enabled = true;
          show_location = true;
          animation = {
            enabled = true;
            speed = 1.0;
          };
        };

        # Catppuccin built-in palette, dark by default. The light variant is
        # driven by the `light` specialisation on tars (theme.mode -> "light").
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };

        wallpaper = {
          enabled = true;
          fill_mode = "crop";
          directory = "/home/daniel/Pictures/Wallpapers";
          transition_duration = 1500;
          # Seed the active wallpaper. noctalia treats wallpaper.default as
          # app-managed state (written to ~/.local/state/noctalia/settings.toml
          # when changed via the GUI), so this only sets the initial default.
          default = {
            path = "/home/daniel/Pictures/Wallpapers/wallhaven_x6x3gz.jpg";
          };
        };

        # Top bar. v4 widgets mapped to v5 ids; the old VPN and Microphone bar
        # widgets have no v5 equivalent and were dropped (mic control lives in
        # the volume widget / control center).
        bar = {
          main = {
            position = "top";
            thickness = 34;
            radius = 12;
            # v5 bar margins: margin_edge = distance from the screen edge (>0
            # floats the bar), margin_ends = inset at each end of the bar. 0/0
            # keeps the bar flush. (The old margin_h/margin_v keys are not part
            # of the v5 bar schema and were silently ignored.)
            margin_edge = 0;
            margin_ends = 0;
            padding = 10;
            widget_spacing = 6;
            reserve_space = true;
            shadow = true;
            start = [
              "control-center"
              "workspaces"
            ];
            center = [
              "clock"
              "caffeine"
            ];
            end = [
              "tray"
              "spacer"
              "network"
              "bluetooth"
              "volume"
              "brightness"
              "battery"
              "notifications"
            ];
          };
        };

        # Per-bar-widget settings (keyed by widget id under [widget.*]).
        widget = {
          # German date/time on the clock widget (chrono strftime, not Qt tokens).
          clock = {
            format = "{:%a, %d. %b  %H:%M}";
            vertical_format = "{:%H\n%M}";
            tooltip_format = "{:%A, %d. %b %Y  %H:%M}";
          };
          # Battery as a graphical gauge rather than a glyph.
          battery = {
            display_mode = "graphic";
          };
          # Network widget icon-only (no label text).
          network = {
            show_label = false;
          };
        };

        notification = {
          enable_daemon = true;
          show_app_name = true;
          show_actions = true;
        };

        osd = {
          position = "top_center";
        };

        # UI feedback sounds (volume/notification) via PipeWire — bundled wavs.
        audio = {
          enable_sounds = true;
          sound_volume = 0.5;
        };

        brightness = {
          enable_ddcutil = false;
        };

        nightlight = {
          enabled = false;
        };

        lockscreen = {
          enabled = true;
        };

        weather = {
          enabled = true;
          unit = "celsius";
          refresh_minutes = 30;
          effects = true;
        };

        location = {
          auto_locate = false;
          address = "Traunstein, Germany";
        };

        system = {
          monitor = {
            enabled = true;
          };
        };

        # Idle/lock is handled by the hypridle module, not noctalia's built-in
        # [idle] daemon — leave noctalia's idle behaviors disabled (the default)
        # to avoid two idle managers fighting.
      };
    };
  };
}
