{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.openthread-border-router;
in
{
  options.services.flocke.openthread-border-router = {
    enable = mkEnableOption "Enable Open Thread Border Router";

    radioDevice = mkOption {
      type = types.str;
      default = "";
      description = ''
        Serial device path for the Thread radio.
        For Home Assistant Connect ZBT-2, use:
        /dev/serial/by-id/usb-Nabu_Casa_ZBT-2_*-if00

        Find the exact device with: ls /dev/serial/by-id/usb-Nabu_Casa_*
      '';
    };

    backboneInterface = mkOption {
      type = types.str;
      default = "eth0";
      description = ''
        Network interface for the Thread network backbone.
        This connects the Thread mesh to your main network.
      '';
    };

    webInterface = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the web interface for OTBR management";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.radioDevice != "";
        message = "services.flocke.openthread-border-router.radioDevice must be set to your Thread radio device path";
      }
    ];

    services.openthread-border-router = {
      enable = true;
      package = pkgs.openthread-border-router;

      radio = {
        device = cfg.radioDevice;
        baudRate = 460800; # ZBT-2 specific
        flowControl = true; # Required for ZBT-2
      };

      inherit (cfg) backboneInterface;

      rest = {
        listenAddress = "127.0.0.1";
        listenPort = 8081;
      };

      web = {
        enable = cfg.webInterface;
        listenAddress = "127.0.0.1";
        listenPort = 8082;
      };
    };

    # Ensure Avahi is enabled for mDNS/DNS-SD
    # (Already enabled on ava, but enforce the dependency)
    services.avahi.enable = true;
  };
}
