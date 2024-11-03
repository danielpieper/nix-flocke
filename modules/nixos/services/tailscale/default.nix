{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.tailscale;
in
{
  options.services.flocke.tailscale = {
    enable = mkEnableOption "Enable tailscale";
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}
