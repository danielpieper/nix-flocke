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
    kernelParams = [
      "consoleblank=300"
      "usbcore.autosuspend=-1" # Disable USB autosuspend for Thread Border Router stability
    ];
  };

  hardware.bluetooth.enable = true;
  networking.networkmanager.wifi.powersave = true;

  # TLP USB blacklist for Thread Border Router
  # Prevent TLP from managing power for ZBT-2 device
  services.tlp.settings = {
    USB_BLACKLIST = "303a:831a"; # Nabu Casa ZBT-2
  };

  system.stateVersion = "23.11";
}
