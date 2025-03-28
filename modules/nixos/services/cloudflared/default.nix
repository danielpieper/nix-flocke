{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.cloudflared;
in
{
  options.services.flocke.cloudflared = {
    enable = mkEnableOption "Enable The cloudflared (tunnel) service";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      cloudflared = { };
      cloudflared-cert = { };
    };

    # https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
    boot.kernel.sysctl."net.core.rmem_max" = 7500000;
    boot.kernel.sysctl."net.core.wmem_max" = 7500000;

    services = {
      cloudflared = {
        enable = true;
        # TODO: Remove when https://github.com/NixOS/nixpkgs/issues/370185 is resolved
        package = pkgs.flocke.cloudflared;
        tunnels = {
          "4488062b-53ae-4932-ba43-db4804831f8a" = {
            credentialsFile = config.sops.secrets.cloudflared.path;
            certificateFile = config.sops.secrets.cloudflared-cert.path;
            default = "http_status:404";
          };
        };
      };
    };
  };
}
