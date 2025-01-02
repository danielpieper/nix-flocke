{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.arr;
in
{
  options.services.flocke.arr = {
    enable = mkEnableOption "Enable the arr";
  };

  config = mkIf cfg.enable {
    users.groups.media = { };

    # TODO: remove when https://github.com/NixOS/nixpkgs/issues/360592 is resolved
    nixpkgs.config.permittedInsecurePackages = [
      "aspnetcore-runtime-6.0.36"
      "aspnetcore-runtime-wrapped-6.0.36"
      "dotnet-sdk-6.0.428"
      "dotnet-sdk-wrapped-6.0.428"
    ];

    services = {
      bazarr = {
        enable = true;
        group = "media";
      };

      lidarr = {
        enable = true;
        group = "media";
      };
      readarr = {
        enable = true;
        group = "media";
      };
      radarr = {
        enable = true;
        group = "media";
      };

      prowlarr.enable = true;
      sonarr = {
        enable = true;
        group = "media";
      };

      # flaresolverr = {
      #   enable = true;
      #   port = 8191;
      #   openFirewall = true;
      # };

      jellyseerr.enable = true;

      cloudflared = {
        tunnels = {
          "4488062b-53ae-4932-ba43-db4804831f8a" = {
            ingress = {
              "jellyseerr.daniel-pieper.com" = "http://localhost:5055";
            };
          };
        };
      };

      traefik = {
        dynamicConfigOptions = {
          http = {
            services = {
              bazarr.loadBalancer.servers = [
                {
                  url = "http://localhost:6767";
                }
              ];
              readarr.loadBalancer.servers = [
                {
                  url = "http://localhost:8787";
                }
              ];
              lidarr.loadBalancer.servers = [
                {
                  url = "http://localhost:8686";
                }
              ];
              radarr.loadBalancer.servers = [
                {
                  url = "http://localhost:7878";
                }
              ];
              prowlarr.loadBalancer.servers = [
                {
                  url = "http://localhost:9696";
                }
              ];
              sonarr.loadBalancer.servers = [
                {
                  url = "http://localhost:8989";
                }
              ];
              jellyseerr.loadBalancer.servers = [
                {
                  url = "http://localhost:5055";
                }
              ];
            };

            routers = {
              bazarr = {
                entryPoints = [ "websecure" ];
                rule = "Host(`bazarr.homelab.daniel-pieper.com`)";
                service = "bazarr";
                tls.certResolver = "letsencrypt";
                middlewares = [ "authentik" ];
              };
              readarr = {
                entryPoints = [ "websecure" ];
                rule = "Host(`readarr.homelab.daniel-pieper.com`)";
                service = "readarr";
                tls.certResolver = "letsencrypt";
                middlewares = [ "authentik" ];
              };
              lidarr = {
                entryPoints = [ "websecure" ];
                rule = "Host(`lidarr.homelab.daniel-pieper.com`)";
                service = "lidarr";
                tls.certResolver = "letsencrypt";
                middlewares = [ "authentik" ];
              };
              radarr = {
                entryPoints = [ "websecure" ];
                rule = "Host(`radarr.homelab.daniel-pieper.com`)";
                service = "radarr";
                tls.certResolver = "letsencrypt";
                middlewares = [ "authentik" ];
              };
              prowlarr = {
                entryPoints = [ "websecure" ];
                rule = "Host(`prowlarr.homelab.daniel-pieper.com`)";
                service = "prowlarr";
                tls.certResolver = "letsencrypt";
                middlewares = [ "authentik" ];
              };
              sonarr = {
                entryPoints = [ "websecure" ];
                rule = "Host(`sonarr.homelab.daniel-pieper.com`)";
                service = "sonarr";
                tls.certResolver = "letsencrypt";
                middlewares = [ "authentik" ];
              };
              jellyseerr = {
                entryPoints = [ "websecure" ];
                rule = "Host(`jellyseerr.homelab.daniel-pieper.com`)";
                service = "jellyseerr";
                tls.certResolver = "letsencrypt";
              };
            };
          };
        };
      };
    };
  };
}
