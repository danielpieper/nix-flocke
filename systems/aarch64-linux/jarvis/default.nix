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

  # nmcli device modify enp1s0 ipv4.method auto

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
