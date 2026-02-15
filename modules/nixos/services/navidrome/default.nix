{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.navidrome;
in
{
  options.services.flocke.navidrome = {
    enable = mkEnableOption "Enable the navidrome service";
  };

  config = mkIf cfg.enable {
    systemd.services.navidrome.unitConfig = {
      RequiresMountsFor = "/mnt/nas/11tb";
    };
    services = {
      navidrome = {
        enable = true;
        settings = {
          MusicFolder = "/mnt/nas/11tb/media/music/library";
          BaseUrl = "https://navidrome.homelab.${inputs.nix-secrets.domain}";
          PlaylistsPath = "playlists";
          ReverseProxyUserHeader = "X-Authentik-Name";
          ReverseProxyWhitelist = "0.0.0.0/0";
        };
      };

      traefik = {
        dynamic.files."navidrome".settings = {
          http = {
            services = {
              navidrome.loadBalancer.servers = [ { url = "http://localhost:4533"; } ];
            };

            routers = {
              navidrome = {
                entryPoints = [ "websecure" ];
                rule = "Host(`navidrome.homelab.${inputs.nix-secrets.domain}`) && !PathPrefix(`/rest/`)";
                priority = 1;
                service = "navidrome";
                middlewares = [ "authentik" ];
              };
              navidrome-api = {
                entryPoints = [ "websecure" ];
                rule = "Host(`navidrome.homelab.${inputs.nix-secrets.domain}`) && PathPrefix(`/rest/`)";
                priority = 99;
                service = "navidrome";
              };
            };
          };
        };
      };
    };
  };
}
