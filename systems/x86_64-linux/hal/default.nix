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

  services.flocke = {
    cloudflared.enable = true;
    traefik.enable = true;
    nfs.enable = true;
    #   postgresql.enable = true;
    #   home-assistant.enable = true;
    searxng.enable = true;
    # adguard.enable = true;
    # teslamate.enable = true;
  };

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
