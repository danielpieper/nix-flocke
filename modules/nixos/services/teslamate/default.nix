{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.teslamate;
in
{
  options.services.flocke.teslamate = {
    enable = mkEnableOption "Enable The teslamate data logger";
  };

  config = mkIf cfg.enable {
    services.teslamate = {
      enable = true;

      # environmentFile = config.sops.secrets.searx.path;
    };
  };
}
