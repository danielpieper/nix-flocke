{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.roles.desktop.addons.niri;
in
{
  options.roles.desktop.addons.niri = with types; {
    enable = mkBoolOpt false "Enable or disable the niri window manager.";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    programs.niri = {
      enable = true;
    };

    programs.uwsm = {
      enable = true;
      waylandCompositors = {
        niri = {
          prettyName = "Niri";
          comment = "Niri compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/niri-session";
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
