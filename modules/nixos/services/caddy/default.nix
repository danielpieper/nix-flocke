{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.caddy;
  domain = inputs.nix-secrets.homelabDomain;
in
{
  options.services.flocke.caddy = {
    enable = mkEnableOption "Enable caddy reverse proxy";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    sops.secrets.caddy_env = { };

    security.acme = {
      acceptTerms = true;
      defaults.email = inputs.nix-secrets.caddy.acmeEmail;
      certs."${domain}" = {
        dnsProvider = "hetzner";
        environmentFile = config.sops.secrets.caddy_env.path;
        dnsResolver = "1.1.1.1:53";
        inherit domain;
        extraDomainNames = [ "*.${domain}" ];
        inherit (config.services.caddy) group;
      };
    };

    services.caddy = {
      enable = true;
      globalConfig = ''
        auto_https disable_redirects
      '';
      virtualHosts."http://" = {
        extraConfig = ''
          redir https://{host}{uri} permanent
        '';
      };
    };
  };
}
