{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.flocke.shotwell;
in
{
  options.programs.flocke.shotwell = {
    enable = mkEnableOption "Enable shotwell program";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      shotwell
    ];
  };
}
