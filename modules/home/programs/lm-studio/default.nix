{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.flocke.lm-studio;
in
{
  options.programs.flocke.lm-studio = {
    enable = mkEnableOption "LM Studio";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.lmstudio ];
  };
}
