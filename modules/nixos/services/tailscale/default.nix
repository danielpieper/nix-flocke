{
  config,
  lib,
  # pkgs,
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
    # https://github.com/NixOS/nixpkgs/issues/438765#issuecomment-3281041188
    # services.tailscale.package = pkgs.tailscale.overrideAttrs { doCheck = false; };

    # https://github.com/tailscale/tailscale/issues/10319#issuecomment-1886730614
    networking.firewall.checkReversePath = "loose";
  };
}
