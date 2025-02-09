{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.desktops.addons.hyprlock;
in
{
  options.desktops.addons.hyprlock = with types; {
    enable = mkBoolOpt false "Whether to enable the hyprlock";
  };

  config = mkIf cfg.enable {
    programs.hyprlock.enable = true;
  };
}
