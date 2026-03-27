{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.ntfy;
  domain = inputs.nix-secrets.homelabDomain;
in
{
  options.services.flocke.ntfy = {
    enable = mkEnableOption "Enable ntfy push notification service";
  };

  config = mkIf cfg.enable {
    services = {
      ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://ntfy.${domain}";
          listen-http = "127.0.0.1:2586";
          auth-default-access = "read-write"; # Tailscale-only access, no public exposure
          behind-proxy = true;
        };
      };

      caddy.virtualHosts."ntfy.${domain}" = {
        useACMEHost = domain;
        extraConfig = "reverse_proxy 127.0.0.1:2586";
      };
    };
  };
}
