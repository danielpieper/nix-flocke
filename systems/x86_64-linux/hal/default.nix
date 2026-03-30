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
    caddy.enable = true;
    nfs.enable = true;
    jellyfin.enable = true;
    navidrome.enable = true;
    postgresql.enable = true;
    monitoring.enable_exporter = true;
    restic = {
      enable = true;
      excludes = [
        "var/lib/docker"
        "var/lib/containers"
        "var/lib/arr"
        "jellyfin/metadata"
      ];
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
