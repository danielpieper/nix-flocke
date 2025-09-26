{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.hardware.networking;
in
{
  options.hardware.networking = with types; {
    enable = mkBoolOpt false "Enable networkmanager";
  };

  config = mkIf cfg.enable {
    networking = {
      firewall = {
        enable = true;
        # TODO: check the reason for this:
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
        allowedUDPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
      };
      # Configure networkmanager connections to only use DHCP without DNS settings
      networkmanager = {
        enable = true;
        # dns = "none";
      };
      useDHCP = false;
      dhcpcd.enable = false;
      resolvconf.enable = false;
      inherit (inputs.nix-secrets.networking) nameservers;
    };
    services.resolved = {
      enable = true;
      # At the time of September 2023, systemd upstream advise to disable DNSSEC by default as the current code is not robust enough
      # to deal with “in the wild” non-compliant servers, which will usually give you a broken bad experience in addition of insecure.
      dnssec = "false";
      domains = [ "~." ];
      fallbackDns = inputs.nix-secrets.networking.fallbackNameservers;
      dnsovertls = "opportunistic";
      extraConfig = ''
        MulticastDNS=no
        LLMNR=no
      '';
    };
    # systemd.services.systemd-resolved.environment.SYSTEMD_LOG_LEVEL = "debug";
  };
}
