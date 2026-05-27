{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.cloudflared;
in
{
  options.services.flocke.cloudflared = {
    enable = mkEnableOption "Cloudflare Tunnel (token-based / dashboard-managed)";
  };

  config = mkIf cfg.enable {
    # The sops secret holds an EnvironmentFile line: TUNNEL_TOKEN=<token from the dashboard>.
    sops.secrets.cloudflared_token = { };

    # The upstream services.cloudflared module targets locally-managed tunnels
    # (credentials file + ingress). For a dashboard-managed tunnel the ingress
    # lives in Cloudflare, so we just run `cloudflared tunnel run` with the token.
    systemd.services.cloudflared-tunnel = {
      description = "Cloudflare Tunnel";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        EnvironmentFile = config.sops.secrets.cloudflared_token.path;
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared --no-autoupdate tunnel run";
        Restart = "always";
        RestartSec = "5s";
        DynamicUser = true;
      };
    };
  };
}
