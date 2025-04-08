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
    traefik.enable = true;
    authentik.enable = true;
    nfs.enable = true;
    jellyfin.enable = true;
    teslamate.enable = true;
    postgresql.enable = true;
    monitoring = {
      enable = true;
      enable_mullvad = false;
    };
    gotify.enable = true;
    restic.enable_server = true;
    syncthing.enable = true;
    forgejo = {
      enable = true;
      enable-runner = true;
      enable-dump = true;
    };
    arr.enable = true;
    miniflux.enable = true;

    satisfactory.enable = false;
    actual.enable = false;
    valheim.enable = false;
    tandoor.enable = true;
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
