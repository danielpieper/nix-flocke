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

      traefik = {
        dynamicConfigOptions = {
          http = {
            # Define middleware for redirecting www to non-www
            middlewares = {
              redirect-www-to-root = {
                redirectRegex = {
                  regex = "^https?://www\\.(.*)";
                  replacement = "https://$1";
                  permanent = true;
                };
              };
            };

            services = {
              nginx.loadBalancer.servers = [
                {
                  url = "http://localhost:8099";
                }
              ];
            };

            routers = {
              nginx = {
                entryPoints = [ "websecure" ];
                rule = "Host(`${inputs.nix-secrets.domain}`) || Host(`www.${inputs.nix-secrets.domain}`)";
                middlewares = [ "redirect-www-to-root" ];
                service = "nginx";
                tls.certResolver = "letsencrypt";
              };
            };
          };
        };
      };
    };
  };
}
