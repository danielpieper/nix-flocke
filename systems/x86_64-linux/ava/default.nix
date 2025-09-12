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
    };
    logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
  };

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
    kernelParams = [ "consoleblank=300" ];
  };

  system.stateVersion = "23.11";
}
