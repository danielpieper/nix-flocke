{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.system.impermanence;
in
{
  options.system.impermanence = with types; {
    enable = mkBoolOpt false "Enable impermanence";
  };

  config = mkIf cfg.enable {
    security.sudo.extraConfig = ''
      # rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';

    programs.fuse.userAllowOther = true;

    # This script does the actual wipe of the system
    # So if it doesn't run, the btrfs system effectively acts like a normal system
    # Taken from https://github.com/NotAShelf/nyx/blob/2a8273ed3f11a4b4ca027a68405d9eb35eba567b/modules/core/common/system/impermanence/default.nix
    boot.initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root subvolume to a pristine state";
      wantedBy = [ "initrd.target" ];
      requires = [
        "dev-disk-by\\x2dlabel-nixos.device"
      ];
      after = [
        "dev-disk-by\\x2dlabel-nixos.device"
        "systemd-cryptsetup@enc.service"
      ];
      # mount the root fs before clearing
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir /tmp -p
        MNTPOINT=$(mktemp -d)
        (
          mount -t btrfs -o subvol=/ /dev/disk/by-label/nixos "$MNTPOINT"
          trap 'umount "$MNTPOINT"' EXIT

          echo "Creating needed directories"
          mkdir -p "$MNTPOINT"/persist/var/lib/nixos
          mkdir -p "$MNTPOINT"/persist/var/lib/systemd

          echo "Cleaning root subvolume"
          btrfs subvolume list -o "$MNTPOINT/root" | cut -f9 -d ' ' |
          while read -r subvolume; do
            btrfs subvolume delete "$MNTPOINT/$subvolume"
          done && btrfs subvolume delete "$MNTPOINT/root"

          echo "Restoring blank subvolume"
          btrfs subvolume snapshot "$MNTPOINT/root-blank" "$MNTPOINT/root"
        )
      '';
    };

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/srv"
        "/.cache/nix/"
        "/etc/NetworkManager/system-connections"
        "/var/cache/"
        "/var/db/sudo/"
        "/var/lib/"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };
}
