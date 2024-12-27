{
  config,
  lib,
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
      networkmanager.enable = true;
      nameservers = [
        "45.90.28.0#e4e166.dns.nextdns.io"
        "2a07:a8c0::#e4e166.dns.nextdns.io"
        "45.90.30.0#e4e166.dns.nextdns.io"
        "2a07:a8c1::#e4e166.dns.nextdns.io"
      ];
    };

    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
    systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

    services.resolved = {
      enable = true;
      dnssec = "true";
      domains = [ "~." ];
      fallbackDns = [
        "45.90.28.0#e4e166.dns.nextdns.io"
        "2a07:a8c0::#e4e166.dns.nextdns.io"
        "45.90.30.0#e4e166.dns.nextdns.io"
        "2a07:a8c1::#e4e166.dns.nextdns.io"
      ];
      dnsovertls = "true";
    };
  };

}
