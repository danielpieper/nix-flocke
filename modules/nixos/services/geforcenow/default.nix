{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.geforcenow;
in
{
  options.services.flocke.geforcenow = {
    enable = mkEnableOption "Enable NVIDIA GeForce NOW cloud gaming service";
  };

  config = mkIf cfg.enable {
    services.flatpak.enable = true;
    programs.gamescope.enable = true;
    environment.systemPackages = [ pkgs.flocke.geforcenow ];
  };
}
