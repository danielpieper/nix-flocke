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
in
{
  options.services.flocke.website = {
    enable = mkEnableOption "Enable ${inputs.nix-secrets.domain} hosting";
  };

  config = mkIf cfg.enable {

    services = {
      nginx = {
        enable = true;
        defaultListen = [
          {
            addr = "127.0.0.1";
            port = 8099;
          }
        ];
        virtualHosts = {
          "${inputs.nix-secrets.domain}" = {
            forceSSL = false;
            enableACME = false;
            serverAliases = [
              "www.${inputs.nix-secrets.domain}"
            ];
            locations."/" = {
              root = "/var/lib/${inputs.nix-secrets.domain}";
            };
          };
        };
        recommendedTlsSettings = true;
        recommendedProxySettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        clientMaxBodySize = "300m";
      };

    };
  };
}
