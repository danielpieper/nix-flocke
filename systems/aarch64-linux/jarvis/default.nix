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

  system.impermanence.enable = true;

  roles = {
    server.enable = true;
  };

  services = {
    fail2ban.enable = true;
    flocke = {
      restic.enable = true;
      monitoring.enable_exporter = true;
      traefik.enable = true;
      postgresql.enable = true;
    };
  };

  topology.self = {
    hardware.info = "Hetzner VPS";
  };

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
  };

  system.stateVersion = "23.11";
}