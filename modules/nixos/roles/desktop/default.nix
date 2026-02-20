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
      dygmaKeyboard.enable = true;
    };

    programs.regreet.enable = true;

    services = {
      flocke = {
        # systemd-resolved[810]: mDNS-IPv4: There appears to be another mDNS responder running, or previously systemd-resolved crashed with some outstanding transfers.
        # avahi.enable = true;
        restic.enable = true;
        virtualisation.podman.enable = true;
        tailscale.enable = true;
      };
      upower.enable = true;
      logind.settings.Login.HandlePowerKey = "suspend";
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
