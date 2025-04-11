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
    desktop = {
      enable = true;
      addons = {
        hyprland.enable = true;
      };
    };
  };

  services = {
    flocke = {
      tlp.enable = true;
    };
    fprintd.enable = true;
  };

  networking.hostName = "case";

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
  };

  system.stateVersion = "23.11";
}
