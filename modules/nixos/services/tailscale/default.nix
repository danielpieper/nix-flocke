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

    # https://github.com/tailscale/tailscale/issues/10319#issuecomment-1886730614
    networking.firewall.checkReversePath = "loose";
  };
}
