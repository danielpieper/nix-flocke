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
          BaseUrl = "";
          PlaylistsPath = "playlists";
        };
      };

      caddy.virtualHosts."navidrome.${inputs.nix-secrets.homelabDomain}" = {
        useACMEHost = inputs.nix-secrets.homelabDomain;
        extraConfig = "reverse_proxy localhost:4533";
      };
    };
  };
}
