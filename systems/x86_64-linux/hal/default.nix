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

  roles = {
    server.enable = true;
  };

  # services.flocke = {
  #   traefik.enable = true;
  #   postgresql.enable = true;
  #   home-assistant.enable = true;
  #   adguard.enable = true;
  # };

  topology.self = {
    hardware.info = "Dell Optiplex 9020";
  };

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
  };

  system.stateVersion = "23.11";
}
