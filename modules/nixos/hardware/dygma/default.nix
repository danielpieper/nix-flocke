{ lib
, config
, ...
}:
with lib;
with lib.flocke;
let
  cfg = config.hardware.dygmaKeyboard;
in
{
  options.hardware.dygmaKeyboard = with types; {
    enable = mkBoolOpt false "Enable Dygma Bazecor application for their keyboards";
  };

  config = mkIf cfg.enable {
    programs.bazecor.enable = true;
  };
}
