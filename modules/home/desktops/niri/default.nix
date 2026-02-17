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
  cfg = config.desktops.niri;
in
{
  imports = lib.snowfall.fs.get-non-default-nix-files ./.;

  options.desktops.niri = {
    enable = mkEnableOption "Enable niri window manager";
    execOnceExtras = mkOpt (listOf str) [ ] "Extra programs to exec once";
  };

  config = mkIf cfg.enable {
    desktops.addons = {
      kanshi.enable = true;
      # rofi.enable = true;
      # swaync.enable = true;
      # swaylock.enable = true;
      noctalia.enable = true;
      # wlogout.enable = true;
      wlsunset.enable = true;
      # hyprlock.enable = true;
      hypridle.enable = true;
    };

    home.packages = with pkgs; [
      nwg-displays
      # blueman
      # networkmanagerapplet
      wlopm # For DPMS control with swayidle
    ];
  };
}
