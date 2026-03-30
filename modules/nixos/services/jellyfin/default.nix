{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.jellyfin;
in
{
  options.services.flocke.jellyfin = {
    enable = mkEnableOption "Enable jellyfin service";
  };

  config = mkIf cfg.enable {
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        libva-vdpau-driver
        intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
        vpl-gpu-rt # QSV on 11th gen or newer
      ];
    };

    services = {
      jellyfin = {
        enable = true;
        openFirewall = true;
      };

      caddy.virtualHosts."jellyfin.${inputs.nix-secrets.homelabDomain}" = {
        useACMEHost = inputs.nix-secrets.homelabDomain;
        extraConfig = "reverse_proxy localhost:8096";
      };
    };
  };
}
