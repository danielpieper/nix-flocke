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
    programs.niri = {
      settings = {
        # https://github.com/sodiboo/niri-flake/blob/main/docs.md
        xwayland-satellite = {
          enable = true;
          path = lib.getExe pkgs.xwayland-satellite;
        };
        input = {
          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "10%";
          };
          keyboard = {
            xkb = {
              layout = "de(us)";
              options = "caps:escape";
            };
          };

          touchpad = {
            tap = true;
            natural-scroll = true;
            click-method = "clickfinger";
            # dwt = false;
          };

          # General mouse settings (applies to all mice)
          mouse = {
            accel-profile = "flat";
            accel-speed = 0.0;
            natural-scroll = false;
          };

          # Trackball settings
          trackball = {
            accel-profile = "adaptive";
            accel-speed = -0.5;
          };
        };

        layout = {
          gaps = 1;
          center-focused-column = "never";
          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
          ];
          default-column-width = {
            proportion = 0.5;
          };
          border = {
            enable = false;
          };
          focus-ring = {
            enable = true;
            width = 1;
          };
        };

        prefer-no-csd = true;

        hotkey-overlay.skip-at-startup = true;

        spawn-at-startup = [
          { command = [ "${pkgs.kanshi}/bin/kanshi" ]; }
          { command = [ "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" ]; }
          {
            command = [
              "${pkgs.clipse}/bin/clipse"
              "-listen"
            ];
          }
          {
            command = [
              "${pkgs.solaar}/bin/solaar"
              "-w"
              "hide"
            ];
          }
          # { command = [ "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnect-indicator" ]; }
          {
            command = [
              "${pkgs._1password-gui}/bin/1password"
              "--silent"
            ];
          }
          # { command = [ "${pkgs.networkmanagerapplet}/bin/nm-applet" ]; }
          # { command = [ "${pkgs.blueman}/bin/blueman-applet" ]; }
        ]
        ++ (map (cmd: {
          command = [
            "${pkgs.bash}/bin/bash"
            "-c"
            cmd
          ];
        }) cfg.execOnceExtras);

        # Animations
        animations = {
          enable = true;
        };

        # noctalia settings
        # https://docs.noctalia.dev/getting-started/compositor-settings/niri/
        # window-rules = [
        #   {
        #     # Rounded corners for a modern look.
        #     geometry-corner-radius = {
        #       bottom-left = 20.0;
        #       bottom-right = 20.0;
        #       top-left = 20.0;
        #       top-right = 20.0;
        #     };
        #
        #     # Clips window contents to the rounded corner boundaries.
        #     clip-to-geometry = true;
        #   }
        # ];

        debug = {
          honor-xdg-activation-with-invalid-serial = [ ];
        };
      };
    };
  };
}
