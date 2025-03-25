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

  services.flocke = {
    cloudflared.enable = true;
    traefik.enable = true;
    authentik.enable = true;
    nfs.enable = true;
    jellyfin.enable = true;
    teslamate.enable = true;
    postgresql.enable = true;
    monitoring = {
      enable = true;
      enable_mullvad = false;
    };
    gotify.enable = true;
    restic.enable_server = true;
    syncthing.enable = true;
    forgejo = {
      enable = true;
      enable-runner = true;
      enable-dump = true;
    };
    arr.enable = true;

    satisfactory.enable = false;
    actual.enable = false;
    valheim.enable = false;
    tandoor.enable = false;
  };

  topology.self = {
    hardware.info = "Dell Optiplex 9020";
  };

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
  };

  # teslamate is unable to connect to teslamotors.com
  # if the tailscale mullvad exit node is enabled.
  #
  # sudo tailscale exit-node suggest
  # sudo tailscale set --exit-node=<EXIT_NODE> --exit-node-allow-lan-access=true
  # nslookup teslamotors.com
  # sudo ip route add <IP_ADDRESS> via <ROUTER_IP_ADDRESS>
  # networking.interfaces.eno1.ipv4.routes = [
  #   {
  #     address = "209.11.133.106";
  #     prefixLength = 24;
  #     via = "192.168.178.1";
  #   }
  # ];

  system.stateVersion = "23.11";
}
