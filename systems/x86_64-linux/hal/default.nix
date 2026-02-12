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
    authentik.enable = true;
    nfs.enable = true;
    jellyfin.enable = true;
    navidrome.enable = true;
    teslamate = {
      enable = true;
      runMigrations = false;
    };
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
      enable-runner = false;
      enable-dump = true;
    };
    arr.enable = true;
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
