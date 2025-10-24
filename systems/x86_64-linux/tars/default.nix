{
  config,
  inputs,
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
    gaming.enable = true;
  };

  environment.systemPackages = with pkgs; [
    moonlight-qt
    vlc
  ];

  services = {
    flocke.syncthing.enable = true;

    # Let TUXEDO Control Center handle CPU frequencies
    power-profiles-daemon.enable = false;
  };

  networking.hostName = "tars";

  security.flocke = {
    ausweisapp.enable = true;
  };

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    # bore scheduler: https://github.com/NixOS/nixpkgs/issues/324859#issuecomment-3263952213
    kernelPatches =
      let
        patchesDir = "${inputs.bore-scheduler-src}/patches/stable/linux-${lib.versions.majorMinor config.boot.kernelPackages.kernel.version}-bore";
      in
      lib.mapAttrsToList (name: _: {
        name = "bore-${name}";
        patch = "${patchesDir}/${name}";
      }) (builtins.readDir patchesDir);
    resumeDevice = "/dev/disk/by-label/nixos";
  };

  hardware.xone.enable = true;

  # https://fnune.com/hardware/2025/07/20/nixos-on-a-tuxedo-infinitybook-pro-14-gen9-amd/
  hardware.tuxedo-control-center.enable = true;
  # hardware.tuxedo-rs = {
  #   enable = true;
  #   tailor-gui.enable = true;
  # };

  system.stateVersion = "23.11";
}
