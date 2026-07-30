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
    tailnetOnly = mkEnableOption ''
      Accept HTTP(S) only on the tailnet interface. Caddy still listens on
      *:80/*:443, so this is what actually keeps the vhosts off the public
      internet — pointing their DNS records at a tailnet address does not,
      since a spoofed Host header against the public IP still reaches them.
      Leave off for hosts serving a genuinely public site. ACME is unaffected:
      certs are issued over DNS-01, which needs no inbound port
    '';
  };

  config = mkIf cfg.enable {
    networking.firewall =
      let
        ports = [
          80
          443
        ];
      in
      if cfg.tailnetOnly then
        { interfaces.tailscale0.allowedTCPPorts = ports; }
      else
        { allowedTCPPorts = ports; };

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
        # NixOS Caddy module uses cert.pem (leaf only), but we need the full chain
        postRun = "cp fullchain.pem cert.pem";
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
