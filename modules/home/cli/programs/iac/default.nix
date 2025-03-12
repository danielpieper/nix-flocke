{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.programs.iac;
in
{
  options.cli.programs.iac = with types; {
    enable = mkBoolOpt false "Whether or not to enable infrastructure as code tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      tenv
      ansible
    ];
  };
}
