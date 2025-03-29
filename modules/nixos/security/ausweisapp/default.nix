{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.security.flocke.ausweisapp;
in
{
  options.security.flocke.ausweisapp = {
    enable = mkBoolOpt false "Whether to enable the Bund ID AusweisApp";
  };

  config = mkIf cfg.enable {
    programs.ausweisapp = {
      enable = true;
      openFirewall = true;
    };
  };
}
