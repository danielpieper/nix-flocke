{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  environment.systemPackages = with pkgs; [
    beets
    ffmpeg
  ];

  system.impermanence.enable = true;

  roles = {
    server.enable = true;
  };

  services.flocke = {
    traefik.enable = true;
    authentik.enable = true;
    nfs.enable = true;
    jellyfin.enable = true;
    navidrome.enable = true;
    teslamate.enable = true;
    postgresql.enable = true;
    monitoring.enable = true;
    gotify.enable = true;
    restic = {
      enable = true;
      enable_server = true;
    };
    syncthing.enable = true;
    forgejo = {
      enable = true;
      enable-runner = true;
      enable-dump = true;
    };
    arr.enable = true;
    # home-assistant.enable = true;
    avahi.enable = true;
  };

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
  };

  system.stateVersion = "23.11";
}
