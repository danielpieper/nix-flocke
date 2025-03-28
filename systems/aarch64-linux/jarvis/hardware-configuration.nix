# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "virtio_pci"
        "virtio_scsi"
        "usbhid"
        "sr_mod"
      ];
      # initialize the display early to get a complete log
      kernelModules = [ "virtio_gpu" ];
    };
    # workaround because the console defaults to serial
    kernelParams = [ "console=tty" ];
  };

  swapDevices = [ ];

  networking = {
    useDHCP = lib.mkDefault true;
    hostName = "jarvis";
    interfaces.enp1s0 = {
      useDHCP = lib.mkDefault true;
      ipv6.addresses = [
        {
          address = "2a01:4f8:c013:869a::";
          prefixLength = 64;
        }
      ];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
