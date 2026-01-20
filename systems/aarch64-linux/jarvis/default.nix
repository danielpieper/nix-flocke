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

  # Define NetworkManager connection with both IPv4 DHCP and static IPv6
  networking.networkmanager.ensureProfiles.profiles.enp1s0 = {
    connection = {
      id = "enp1s0";
      type = "ethernet";
      interface-name = "enp1s0";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      method = "manual";
      address1 = "2a01:4f8:c013:869a::/64";
      gateway = "fe80::1";
    };
  };

  system.impermanence.enable = true;

  roles = {
    server.enable = true;
  };

  services = {
    fail2ban.enable = true;
    flocke = {
      restic.enable = true;
      monitoring.enable_exporter = true;
      traefik.enable = true;
      searxng.enable = true;
      postgresql.enable = true;
      website.enable = true;
      miniflux.enable = true;
      # TODO: error: Package ‘python3.12-chromadb-0.5.20’ is marked as broken, refusing to evaluate.
      openwebui.enable = false;
      n8n.enableWebhook = true;
    };
  };

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
  };

  system.stateVersion = "23.11";
}
