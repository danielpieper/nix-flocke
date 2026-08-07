{
  config,
  lib,
  pkgs,
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
    programs = {
      niri = {
        enable = true;
        # TEMP: niri-flake hardcodes libdisplay-info_0_2, which nixpkgs 26.11
        # removed. Its niri-stable (25.08) still needs that lib, so use the
        # nixpkgs build (26.04) instead. Drop once niri-flake moves to 0_3.
        package = pkgs.niri;
      };

      uwsm = {
        enable = true;
        waylandCompositors.niri = {
          prettyName = "Niri";
          comment = "Niri compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/niri-session";
        };
      };
    };

    roles.desktop.addons.xdg-portal.enable = true;
  };
}
