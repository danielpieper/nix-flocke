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
    services = {
      openthread-border-router = {
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
      # Enforce avahi dependency for mDNS/DNS-SD
      avahi.enable = true;
    };

    # Allow Thread devices to access infrastructure network for Matter/CHIP
    # OTBR firewall blocks Thread devices from reaching local network by default
    # This adds infrastructure ULA prefix to the allow list
    # Also disables NAT64 to prevent harmless warning messages
    systemd.services.otbr-allow-infrastructure = {
      description = "Allow Thread devices to access infrastructure network";
      after = [ "otbr-agent.service" ];
      requires = [ "otbr-agent.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        # Wait for otbr-agent to create ipsets and initialize
        sleep 3

        # Add infrastructure ULA prefix to allow list
        ${pkgs.ipset}/bin/ipset add otbr-ingress-allow-dst fd00::/64 || true

        # Disable NAT64 to prevent infrastructure discovery warnings
        # NAT64 is not needed when infrastructure network has IPv4 connectivity
        /run/current-system/sw/bin/ot-ctl nat64 disable || true
      '';
    };
  };
}
