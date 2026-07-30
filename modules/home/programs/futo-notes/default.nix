{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.flocke.futo-notes;
in
{
  options.programs.flocke.futo-notes = {
    enable = mkEnableOption "FUTO Notes desktop client";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.flocke.futo-notes ];
  };
}
