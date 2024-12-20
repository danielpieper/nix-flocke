{
  lib,
  config,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.roles.desktop;
in
{
  options.roles.desktop = {
    enable = mkEnableOption "Enable desktop configuration";
  };

  config = mkIf cfg.enable {
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    roles = {
      common.enable = true;

      desktop.addons = {
        nautilus.enable = true;
        _1password.enable = true;
      };
    };

    hardware = {
      audio.enable = true;
      bluetooth.enable = true;
      logitechMouse.enable = true;
    };

    services.flocke = {
      avahi.enable = true;
      restic.enable = true;
      virtualisation.podman.enable = true;
        tailscale.enable = true;
    };

    system = {
      boot.plymouth = true;
    };

    cli.programs = {
      nh.enable = true;
      nix-ld.enable = true;
    };

    user = {
      name = "daniel";
    };
  };
}
