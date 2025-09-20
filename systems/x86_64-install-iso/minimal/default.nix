{ lib, config, ... }:
{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Add Motorcomm YT6801 Driver if available
    extraModulePackages =
      with config.boot;
      lib.lists.optional (kernelPackages ? yt6801) kernelPackages.yt6801;
  };

  networking.wireless.enable = lib.mkForce false;
  networking.networkmanager.enable = true;

  nix.enable = true;
  services = {
    openssh.enable = true;
  };

  system = {
    locale.enable = true;
  };

  user = {
    name = "nixos";
  };

  system.stateVersion = "23.11";
}
