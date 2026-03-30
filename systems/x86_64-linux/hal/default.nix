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

  environment.systemPackages = with pkgs; [ ffmpeg ];

  system.impermanence.enable = true;

  roles = {
    server.enable = true;
  };

  services.flocke = {
    traefik.enable = true;
    nfs.enable = true;
    jellyfin.enable = true;
    navidrome.enable = true;
    postgresql.enable = true;
    monitoring.enable_exporter = true;
    restic = {
      enable = true;
      enable_server = true;
    };
    syncthing.enable = true;
    arr.enable = false;
    avahi.enable = true;
    evitts.enable = false;
  };

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
  };

  system.stateVersion = "23.11";
}
