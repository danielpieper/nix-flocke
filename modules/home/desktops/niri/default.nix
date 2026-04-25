{
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
      noctalia.enable = true;
    };
  };
}
