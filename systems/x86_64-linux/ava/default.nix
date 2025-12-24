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
    flocke = {
      traefik.enable = true;
      restic.enable = true;
      monitoring.enable_exporter = true;
      projecty.enable = true;
      n8n.enable = true;
      home-assistant.enable = true;
      avahi.enable = true;
      openthread-border-router = {
        enable = true;
        radioDevice = "/dev/serial/by-id/usb-Nabu_Casa_ZBT-2_9C139EAC09F0-if00";
        backboneInterface = "enp0s25";
        webInterface = true;
      };
    };
    logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
  };

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
    kernelParams = [ "consoleblank=300" ];
  };

  hardware.bluetooth.enable = true;
  networking.networkmanager.wifi.powersave = true;

  system.stateVersion = "23.11";
}
