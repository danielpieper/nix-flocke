{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.roles.desktop.addons.hyprland;
in
{
  options.roles.desktop.addons.hyprland = with types; {
    enable = mkBoolOpt false "Enable or disable the hyprland window manager.";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };

    programs.uwsm = {
      enable = true;
      waylandCompositors = {
        hyprland = {
          prettyName = "Hyprland";
          comment = "Hyprland compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/Hyprland";
        };
      };
    };
    environment.loginShellInit = ''
      if uwsm check may-start && uwsm select; then
      	exec uwsm start default
      fi
    '';

    roles.desktop.addons.xdg-portal.enable = true;
  };
}
