{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  system = {
    impermanence.enable = true;
    # Disable the default EFI boot module — this host uses BIOS
    boot.enable = lib.mkForce false;
    stateVersion = "26.05";
  };

  roles = {
    server.enable = true;
  };

  services.flocke = {
    caddy.enable = true;
    postgresql.enable = true;
    authelia.enable = true;
    ntfy.enable = true;
    monitoring.enable = true;
    forgejo = {
      enable = true;
      enable-runner = false;
      enable-dump = false;
    };
    miniflux.enable = true;
    mealie.enable = true;
    immich.enable = true;
    paperless.enable = true;
    filebrowser.enable = true;
    # Run Syncthing as the filebrowser user so synced folders are
    # directly accessible in Filebrowser's per-user directories.
    syncthing = {
      enable = true;
      inherit (config.services.filebrowser) user group;
      dataDir = config.services.filebrowser.settings.root;
    };
    restic = {
      enable = true;
      excludes = [
        "var/lib/containers"
      ];
      backupPrepareCommand = ''
        ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/pg_dumpall \
          > /persist/var/backup/postgres.sql
      '';
    };
    teslamate = {
      enable = true;
      runMigrations = true;
    };
  };

  # BIOS boot — override the default systemd-boot/EFI config
  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = lib.mkForce false;
      grub.enable = true;
    };
  };
}
