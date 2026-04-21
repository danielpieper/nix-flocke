{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.arr;
in
{
  imports = [
    ./bazarr.nix
    ./seerr.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./lidarr.nix
    ./sabnzbd.nix
  ];

  options.services.flocke.arr = {
    enable = mkEnableOption "Enable the arr";
  };

  config = mkIf cfg.enable {
    environment.interactiveShellInit = ''
      alias arr='sudo nixos-container root-login arr'
    '';

    systemd.tmpfiles.rules = [
      "d /persist/var/lib/arr/caddy 0777 root root"
      "d /persist/var/lib/arr/tailscale 0777 root root"
    ];

    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-arr" ];
      externalInterface = "eno1";
    };

    containers.arr = {
      ephemeral = true;
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.10";
      localAddress = "192.168.100.11";
      enableTun = true;
      bindMounts = {
        "/persist/etc/ssh/" = {
          hostPath = "/persist/etc/ssh/";
          isReadOnly = true;
        };
        "/mnt/" = {
          hostPath = "/mnt/";
          isReadOnly = false;
        };
        "/var/lib/caddy/" = {
          hostPath = "/persist/var/lib/arr/caddy/";
          isReadOnly = false;
        };
        "/var/lib/acme/" = {
          hostPath = "/var/lib/acme/";
          isReadOnly = true;
        };
        "/var/lib/tailscale/" = {
          hostPath = "/persist/var/lib/arr/tailscale/";
          isReadOnly = false;
        };
      };

      config = {
        system.stateVersion = "23.11";

        users.groups.media = { };
        environment.systemPackages = [
          pkgs.ghostty.terminfo
          pkgs.wezterm.terminfo
        ];

        networking = {
          firewall = {
            enable = true;
            # https://github.com/tailscale/tailscale/issues/10319#issuecomment-1886730614
            checkReversePath = "loose";
            allowedTCPPorts = [
              80
              443
            ];
            extraCommands = ''
              # Kill switch: block non-Tailscale outbound traffic on eth0.
              # Tailscale needs UDP (WireGuard) and TCP 443 (DERP relays) to
              # bootstrap; once connected, all app traffic routes via tailscale0.
              iptables -N kill-switch 2>/dev/null || iptables -F kill-switch
              iptables -A kill-switch -o lo -j ACCEPT
              iptables -A kill-switch -o tailscale0 -j ACCEPT
              iptables -A kill-switch -o eth0 -p udp --sport 41641 -j ACCEPT
              iptables -A kill-switch -o eth0 -p tcp --dport 443 -j ACCEPT
              iptables -A kill-switch -o eth0 -p udp --dport 53 -j ACCEPT
              iptables -A kill-switch -o eth0 -p tcp --dport 53 -j ACCEPT
              iptables -A kill-switch -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
              iptables -A kill-switch -o eth0 -j REJECT
              iptables -C OUTPUT -j kill-switch 2>/dev/null || iptables -A OUTPUT -j kill-switch
            '';
            extraStopCommands = ''
              iptables -D OUTPUT -j kill-switch 2>/dev/null || true
              iptables -F kill-switch 2>/dev/null || true
              iptables -X kill-switch 2>/dev/null || true
            '';
          };
          nameservers = inputs.nix-secrets.networking.fallbackNameservers;
        };

        systemd.services.caddy.after = [ "tailscaled.service" ];

        services = {
          tailscale = {
            enable = true;
            disableTaildrop = true;
            extraSetFlags = [
              "--exit-node=${inputs.nix-secrets.networking.tailscale.exitNode}"
            ];
          };
          caddy = {
            enable = true;
            globalConfig = ''
              auto_https disable_redirects
            '';
            extraConfig = ''
              (arr-tls) {
                tls /var/lib/acme/${inputs.nix-secrets.homelabDomain}/cert.pem /var/lib/acme/${inputs.nix-secrets.homelabDomain}/key.pem
              }
            '';
            virtualHosts."http://" = {
              extraConfig = "redir https://{host}{uri} permanent";
            };
          };
        };
      };
    };
  };
}
