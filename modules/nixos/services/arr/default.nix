{
  inputs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.arr;
in
{
  options.services.flocke.arr = {
    enable = mkEnableOption "Enable the arr";
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /persist/var/lib/arr/traefik 0777 root root"
      "d /persist/var/lib/arr/jellyseer 0777 root root"
      "d /persist/var/lib/arr/sonarr 0777 root root"
      "d /persist/var/lib/arr/prowlarr 0777 root root"
      "d /persist/var/lib/arr/radarr 0777 root root"
      "d /persist/var/lib/arr/readarr 0777 root root"
      "d /persist/var/lib/arr/lidarr 0777 root root"
      "d /persist/var/lib/arr/bazarr 0777 root root"
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
        "/var/lib/jellyseer/" = {
          hostPath = "/persist/var/lib/arr/jellyseer/";
          isReadOnly = false;
        };
        "/var/lib/sonarr/" = {
          hostPath = "/persist/var/lib/arr/sonarr/";
          isReadOnly = false;
        };
        "/var/lib/prowlarr/" = {
          hostPath = "/persist/var/lib/arr/prowlarr/";
          isReadOnly = false;
        };
        "/var/lib/radarr/" = {
          hostPath = "/persist/var/lib/arr/radarr/";
          isReadOnly = false;
        };
        "/var/lib/readarr/" = {
          hostPath = "/persist/var/lib/arr/readarr/";
          isReadOnly = false;
        };
        "/var/lib/lidarr/" = {
          hostPath = "/persist/var/lib/arr/lidarr/";
          isReadOnly = false;
        };
        "/var/lib/bazarr/" = {
          hostPath = "/persist/var/lib/arr/bazarr/";
          isReadOnly = false;
        };
        "/var/lib/tailscale/" = {
          hostPath = "/persist/var/lib/arr/tailscale/";
          isReadOnly = false;
        };
      };
      config =
        {
          config,
          pkgs,
          ...
        }:
        {
          imports = [ inputs.sops-nix.nixosModules.sops ];

          users.groups.media = { };
          environment.systemPackages = [ pkgs.ghostty.terminfo ];

          networking = {
            firewall = {
              # enable = true;
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
            prowlarr.serviceConfig.DynamicUser = lib.mkForce false;
          };
          sops = {
            age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
            secrets.cloudflare_api_key.sopsFile = ../secrets.yaml;
          };

          services = {
            tailscale = {
              enable = true;
              disableTaildrop = true;
              permitCertUid = "traefik";
              extraSetFlags = [
                "--exit-node=nl-ams-wg-001.mullvad.ts.net"
                "--exit-node-allow-lan-access"
              ];
            };
            bazarr = {
              enable = true;
              group = "media";
            };
            lidarr = {
              enable = true;
              group = "media";
            };
            readarr = {
              enable = true;
              group = "media";
            };
            radarr = {
              enable = true;
              group = "media";
            };
            sonarr = {
              enable = true;
              group = "media";
            };
            prowlarr.enable = true;
            jellyseerr.enable = true;

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
              dynamicConfigOptions.http = {
                services = {
                  bazarr.loadBalancer.servers = [
                    {
                      url = "http://localhost:6767";
                    }
                  ];
                  readarr.loadBalancer.servers = [
                    {
                      url = "http://localhost:8787";
                    }
                  ];
                  lidarr.loadBalancer.servers = [
                    {
                      url = "http://localhost:8686";
                    }
                  ];
                  radarr.loadBalancer.servers = [
                    {
                      url = "http://localhost:7878";
                    }
                  ];
                  prowlarr.loadBalancer.servers = [
                    {
                      url = "http://localhost:9696";
                    }
                  ];
                  sonarr.loadBalancer.servers = [
                    {
                      url = "http://localhost:8989";
                    }
                  ];
                  jellyseerr.loadBalancer.servers = [
                    {
                      url = "http://localhost:5055";
                    }
                  ];
                };
                routers = {
                  bazarr = {
                    entryPoints = [ "websecure" ];
                    rule = "Host(`bazarr.homelab.daniel-pieper.com`)";
                    service = "bazarr";
                    tls.certResolver = "letsencrypt";
                    # middlewares = [ "authentik" ];
                  };
                  readarr = {
                    entryPoints = [ "websecure" ];
                    rule = "Host(`readarr.homelab.daniel-pieper.com`)";
                    service = "readarr";
                    tls.certResolver = "letsencrypt";
                    # middlewares = [ "authentik" ];
                  };
                  lidarr = {
                    entryPoints = [ "websecure" ];
                    rule = "Host(`lidarr.homelab.daniel-pieper.com`)";
                    service = "lidarr";
                    tls.certResolver = "letsencrypt";
                    # middlewares = [ "authentik" ];
                  };
                  radarr = {
                    entryPoints = [ "websecure" ];
                    rule = "Host(`radarr.homelab.daniel-pieper.com`)";
                    service = "radarr";
                    tls.certResolver = "letsencrypt";
                    # middlewares = [ "authentik" ];
                  };
                  prowlarr = {
                    entryPoints = [ "websecure" ];
                    rule = "Host(`prowlarr.homelab.daniel-pieper.com`)";
                    service = "prowlarr";
                    tls.certResolver = "letsencrypt";
                    # middlewares = [ "authentik" ];
                  };
                  sonarr = {
                    entryPoints = [ "websecure" ];
                    rule = "Host(`sonarr.homelab.daniel-pieper.com`)";
                    service = "sonarr";
                    tls.certResolver = "letsencrypt";
                    # middlewares = [ "authentik" ];
                  };
                  jellyseerr = {
                    entryPoints = [ "websecure" ];
                    rule = "Host(`jellyseerr.homelab.daniel-pieper.com`)";
                    service = "jellyseerr";
                    tls.certResolver = "letsencrypt";
                  };
                };
              };
            };
          };
        };
    };
  };
}
