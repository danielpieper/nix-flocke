{
  lib,
  config,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.programs.btop;
in
{
  options.cli.programs.btop = with types; {
    enable = mkBoolOpt false "Whether or not to enable btop";
  };

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
    };
  };
}
