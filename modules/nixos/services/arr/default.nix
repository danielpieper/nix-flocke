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
    ./jellyseerr.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./premiumizarr.nix
  ];

  options.services.flocke.arr = {
    enable = mkEnableOption "Enable the arr";
  };

  config = mkIf cfg.enable {
    environment.interactiveShellInit = ''
      alias arr='sudo nixos-container root-login arr'
    '';

    systemd.tmpfiles.rules = [
      "d /persist/var/lib/arr/traefik 0777 root root"
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
        "/var/lib/traefik/" = {
          hostPath = "/persist/var/lib/arr/traefik/";
          isReadOnly = false;
        };
        "/var/lib/tailscale/" = {
          hostPath = "/persist/var/lib/arr/tailscale/";
          isReadOnly = false;
        };
      };

      config = {
        imports = [
          inputs.sops-nix.nixosModules.sops
        ];

        users.groups.media = { };
        environment.systemPackages = [ pkgs.ghostty.terminfo ];

        networking = {
          firewall = {
            enable = true;
            # https://github.com/tailscale/tailscale/issues/10319#issuecomment-1886730614
            checkReversePath = "loose";
          };
          nameservers = [ "8.8.8.8" ];
        };

        systemd.services = {
          traefik = {
            environment.CF_API_EMAIL = "cloudflare@daniel-pieper.com";
            serviceConfig.EnvironmentFile = [ config.sops.secrets.cloudflare_api_key.path ];
          };
        };

        sops = {
          age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
          secrets.cloudflare_api_key = { };
        };

        services = {
          tailscale = {
            enable = true;
            disableTaildrop = true;
            permitCertUid = "traefik";
            extraSetFlags = [
              "--exit-node-allow-lan-access"
            ];
          };
          traefik = {
            enable = true;
            staticConfigOptions = {
              metrics.prometheus = { };
              certificatesResolvers.letsencrypt.acme = {
                email = "cloudflare@daniel-pieper.com";
                storage = "/var/lib/traefik/cert.json";
                dnsChallenge = {
                  provider = "cloudflare";
                  resolvers = [
                    "1.1.1.1:53"
                    "8.8.8.8:53"
                  ];
                  disablePropagationCheck = true;
                  delayBeforeCheck = 60;
                };
              };
              entryPoints = {
                web = {
                  address = "0.0.0.0:80";
                  http.redirections.entryPoint = {
                    to = "websecure";
                    scheme = "https";
                    permanent = true;
                  };
                };
                websecure = {
                  address = "0.0.0.0:443";
                  http.tls = {
                    certResolver = "letsencrypt";
                    domains = [
                      {
                        main = "homelab.daniel-pieper.com";
                        sans = [ "*.homelab.daniel-pieper.com" ];
                      }
                    ];
                  };
                };
              };
            };
            dynamicConfigOptions = {
              http = {
                middlewares = {
                  authentik = {
                    forwardAuth = {
                      address = "https://authentik.daniel-pieper.com/outpost.goauthentik.io/auth/traefik";
                      trustForwardHeader = true;
                      authResponseHeaders = [
                        "X-authentik-username"
                        "X-authentik-groups"
                        "X-authentik-email"
                        "X-authentik-name"
                        "X-authentik-uid"
                        "X-authentik-jwt"
                        "X-authentik-meta-jwks"
                        "X-authentik-meta-outpost"
                        "X-authentik-meta-provider"
                        "X-authentik-meta-app"
                        "X-authentik-meta-version"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
