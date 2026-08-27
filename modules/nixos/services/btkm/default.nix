{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.btkm;
  domain = inputs.nix-secrets.homelabDomain;
in
{
  options.services.flocke.btkm = {
    enable = mkEnableOption "Enable btkm web app hosting";
  };

  config = mkIf cfg.enable {
    # Static files only — no backend to reverse_proxy to. The app drives the
    # Pi over Web Bluetooth directly from the browser, which requires a secure
    # context; the wildcard ACME cert supplies it, while tailnetOnly on this
    # host keeps the origin off the public internet.
    services.caddy.virtualHosts."btkm.${domain}" = {
      useACMEHost = domain;
      extraConfig = ''
        root * ${pkgs.flocke.btkm-webapp}
        file_server
      '';
    };
  };
}
