{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.desktops.hyprland;
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      systemd.enableXdgAutostart = true;
      xwayland.enable = true;

      extraConfig = ''
        device {
          name = "kensington-slimblade-pro-trackball(wired)-kensington-slimblade-pro-trackball(wired)";
          accel_profile = "adaptive";
          sensitivity = -0.5;
        }
        device {
          name = "kensington-slimblade-pro(2.4ghz-receiver)-kensington-slimblade-pro-trackball(2.4ghz-receiver)";
          accel_profile = "adaptive";
          sensitivity = -0.5;
        }
        device {
          name = "logitech-g305-1";
          accel_profile = "flat";
          sensitivity = 0;
          natural_scroll = false;
        }
        device {
          name = "logitech-mx-master-3s";
          accel_profile = "flat";
          sensitivity = 0;
          natural_scroll = false;
        }
      '';
      settings = {
        input = {
          kb_layout = "de";
          kb_variant = "us";
          kb_options = "caps:escape";
          touchpad = {
            disable_while_typing = false;
            natural_scroll = true;
          };
        };

        general = {
          gaps_in = 3;
          gaps_out = 5;
          border_size = 3;
        };

        gestures.workspace_swipe = true;
        decoration = {
          rounding = 5;
        };

        dwindle = {
          preserve_split = true;
        };

        misc =
          let
            FULLSCREEN_ONLY = 2;
          in
          {
            vrr = FULLSCREEN_ONLY;
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            force_default_wallpaper = 0;
            # Unfullscreen when opening something
            new_window_takes_over_fullscreen = 2;
          };

        source = [ "${config.home.homeDirectory}/.config/hypr/monitors.conf" ];

        exec-once = [
          "dbus-update-activation-environment --systemd --all"
          "systemctl --user import-environment QT_QPA_PLATFORMTHEME"
          "${pkgs.kanshi}/bin/kanshi"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "${pkgs.clipse}/bin/clipse -listen"
          "${pkgs.solaar}/bin/solaar -w hide"
          "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnect-indicator"
          "${pkgs._1password-gui}/bin/1password --silent"
          "${pkgs.networkmanagerapplet}/bin/nm-applet"
          "${pkgs.blueman}/bin/blueman-applet"
        ] ++ cfg.execOnceExtras;
      };
    };
  };
}
