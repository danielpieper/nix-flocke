{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
with types;
let
  cfg = config.desktops.hyprland;
in
{
  imports = lib.snowfall.fs.get-non-default-nix-files ./.;

  options.desktops.hyprland = {
    enable = mkEnableOption "Enable hyprland window manager";
    execOnceExtras = mkOpt (listOf str) [ ] "Extra programs to exec once";
  };

  config = mkIf cfg.enable {
    nix.settings = {
      trusted-substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    desktops.addons = {
      kanshi.enable = true;
      rofi.enable = true;
      swaync.enable = true;
      waybar.enable = true;
      # hyprpanel.enable = true;
      wlogout.enable = true;
      wlsunset.enable = true;
      hyprpaper.enable = true;
      hyprlock.enable = true;
      hypridle.enable = true;
    };

    home.packages = with pkgs; [
      hyprland-qtutils
      nwg-displays
      blueman
      networkmanagerapplet
    ];
  };
}
