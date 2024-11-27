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
    authentik.enable = true;
    nfs.enable = true;
    jellyfin.enable = true;
    searxng.enable = true;
    teslamate.enable = true;
    postgresql.enable = true;
    monitoring.enable = true;
    gotify.enable = true;
    restic.enable_server = true;
    valheim.enable = false;
    satisfactory.enable = false;
    arr.enable = true;
    syncthing.enable = true;
    #   home-assistant.enable = true;
    # adguard.enable = true;
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
