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

  environment.systemPackages = [ pkgs.moonlight-qt ];

  services = {
    flocke = {
      tlp.enable = true;
      syncthing.enable = true;
    };
    fprintd.enable = true;
  };

  networking.hostName = "tars";

  security.flocke = {
    ausweisapp.enable = true;
  };

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
  };

  system.stateVersion = "23.11";
}
