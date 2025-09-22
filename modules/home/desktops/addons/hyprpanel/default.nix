{
  config,
  lib,
  # pkgs,
  ...
}:
with lib;
let
  cfg = config.desktops.addons.hyprpanel;
in
{
  options.desktops.addons.hyprpanel = {
    enable = mkEnableOption "Enable hyprpanel";
  };

  config = mkIf cfg.enable {
    # home.packages = with pkgs; [
    #   hyprpanel
    # ];
    programs.hyprpanel = {
      enable = true;
      # Configure and theme almost all options from the GUI.
      # See 'https://hyprpanel.com/configuration/settings.html'.
      # Default: <same as gui>
      settings = {
        theme = {
          font = {
            name = "Inter Variable";
            label = "Inter Variable";
            size = "14px";
          };
          bar = {
            buttons = {
              padding_x = "0.5rem";
              padding_y = "0";
              background_opacity = 0;
              monochrome = true;
              workspaces = {
                numbered_active_highlight_padding = "0.4em";
                numbered_active_highlight_border = "0.4em";
              };
            };
          };
        };
        menus.clock.time.military = true;
        menus.clock.weather.enabled = false;
        bar = {
          clock.format = "%a %d. %b %H:%M";
          layouts = {
            "*" = {
              left = [
                "dashboard"
                "workspaces"
                "systray"
                "bluetooth"
                "hyprsunset"
                "hypridle"
              ];
              middle = [
                "clock"
                "media"
              ];
              right = [
                "cpu"
                "ram"
                "cputemp"
                "microphone"
                "volume"
                "battery"
                "network"
                "notifications"
              ];
            };
          };
          launcher.autoDetectIcon = true;
          workspaces = {
            monitorSpecific = false;
            showWsIcons = true;
            showApplicationIcons = true;
            numbered_active_indicator = "highlight";
            spacing = "0.2";
            workspaces = 1;
            showAllActive = false;
          };
          network.truncation = false;
          bluetooth.label = true;
          battery.hideLabelWhenFull = true;
          customModules = {
            storage.paths = [
              "/"
            ];
            microphone.label = false;
            ram.labelType = "used/total";
            hypridle.label = false;
            hyprsunset.label = false;
          };
          notifications.hideCountWhenZero = true;
          notifications.show_total = true;
          media.show_active_only = true;
        };
      };
    };
  };
}
