{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.website;
in
{
  options.services.flocke.website = {
    enable = mkEnableOption "Enable daniel-pieper.com hosting";
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
          "daniel-pieper.com" = {
            forceSSL = false;
            enableACME = false;
            serverAliases = [
              "www.daniel-pieper.com"
            ];
            locations."/" = {
              root = "/var/lib/daniel-pieper.com";
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
                rule = "Host(`daniel-pieper.com`) || Host(`www.daniel-pieper.com`)";
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
