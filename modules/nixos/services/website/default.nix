{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.website;
  inherit (inputs.nix-secrets) domain;
in
{
  options.services.flocke.website = {
    enable = mkEnableOption "Enable ${domain} hosting";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "${domain}" = {
        extraConfig = ''
          root * /var/lib/${domain}
          file_server

        '';
      };
      "www.${domain}" = {
        extraConfig = "redir https://${domain}{uri} permanent";
      };
    };
  };
}
