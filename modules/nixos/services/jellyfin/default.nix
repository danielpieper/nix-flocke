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
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        (intel-vaapi-driver.override { enableHybridCodec = true; }) # i965, VAAPI on Haswell (hal) and older
        libva-vdpau-driver
        intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
        vpl-gpu-rt # QSV on 11th gen or newer
      ];
    };

    # iHD only supports Broadwell and newer; hal is a Haswell i5-4590T
    systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "i965";

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
