{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.monitoring;
in
{
  imports = [
    ./exporter.nix
    ./mullvad.nix
  ];

  options.services.flocke.monitoring = {
    enable = mkEnableOption "Enable The monitoring stack (prometheus, grafana)";
  };

  config = mkIf cfg.enable {
    # Tempo's OTLP receiver is reachable only over the tailnet (where ava's
    # otelcol lives) — never on the public interface.
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 4317 ];

    sops.secrets = {
      grafana_secret_key.owner = "grafana";
      grafana-oidc-client-secret.owner = "grafana";
    };

    services = {
      grafana-to-ntfy = {
        enable = true;
        settings = {
          ntfyUrl = "http://localhost:2586/alerts";
          bauthUser = "admin";
          bauthPass = builtins.toFile "grafana-to-ntfy-pass" inputs.nix-secrets.grafanaToNtfy.password;
        };
      };

      caddy.virtualHosts = {
        "prometheus.${inputs.nix-secrets.homelabDomain}" = {
          useACMEHost = inputs.nix-secrets.homelabDomain;
          extraConfig = ''
            forward_auth 127.0.0.1:9091 {
              uri /api/authz/forward-auth
              copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
            }
            reverse_proxy 127.0.0.1:3020
          '';
        };
        "grafana.${inputs.nix-secrets.homelabDomain}" = {
          useACMEHost = inputs.nix-secrets.homelabDomain;
          extraConfig = "reverse_proxy 127.0.0.1:3010";
        };
      };

      prometheus = {
        port = 3020;
        enable = true;
        checkConfig = "syntax-only";

        exporters = {
          node = {
            port = 3021;
            enabledCollectors = [ "systemd" ];
            enable = true;
          };
        };

        # TODO: work out this is on a different host
        scrapeConfigs = [
          {
            job_name = "nodes";
            static_configs = [
              {
                targets = [
                  "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
                  "ava:${toString config.services.prometheus.exporters.node.port}"
                ];
              }
            ];
          }
        ];
      };

      # Trace backend. ava's otelcol forwards OTLP here over the tailnet
      # (firewall below restricts 4317 to tailscale0). Grafana reads it on
      # localhost:3200 via the Tempo datasource. Local-FS storage, 14d retention.
      tempo = {
        enable = true;
        settings = {
          server.http_listen_address = "127.0.0.1";
          server.http_listen_port = 3200;
          distributor.receivers.otlp.protocols.grpc.endpoint = "0.0.0.0:4317";
          storage.trace = {
            backend = "local";
            wal.path = "/var/lib/tempo/wal";
            local.path = "/var/lib/tempo/blocks";
          };
          compactor.compaction.block_retention = "336h";
        };
      };

      postgresql = {
        ensureDatabases = [ "grafana" ];
        ensureUsers = [
          {
            name = "grafana";
            ensureDBOwnership = true;
          }
        ];
      };

      grafana = {
        enable = true;
        settings = {
          server = {
            http_port = 3010;
            http_addr = "127.0.0.1";
            root_url = "https://grafana.${inputs.nix-secrets.homelabDomain}";
          };

          "auth" = {
            signout_redirect_url = "https://auth.${inputs.nix-secrets.homelabDomain}/logout";
            oauth_auto_login = true;
          };

          "auth.generic_oauth" = {
            enabled = true;
            client_id = "grafana";
            client_secret = "$__file{${config.sops.secrets.grafana-oidc-client-secret.path}}";
            scopes = "openid profile email groups";
            auth_url = "https://auth.${inputs.nix-secrets.homelabDomain}/api/oidc/authorization";
            token_url = "https://auth.${inputs.nix-secrets.homelabDomain}/api/oidc/token";
            api_url = "https://auth.${inputs.nix-secrets.homelabDomain}/api/oidc/userinfo";
            role_attribute_path = "contains(groups, 'admin') && 'Admin' || 'Viewer'";
          };
          database = {
            host = "/run/postgresql";
            user = "grafana";
            name = "grafana";
            type = "postgres";
          };
          security = {
            secret_key = "$__file{${config.sops.secrets.grafana_secret_key.path}}";
          };
        };

        provision = {
          enable = true;
          dashboards.settings = {
            providers = [
              {
                name = "node";
                orgId = 1;
                folder = "Node";
                folderUid = "Nr0ofiDZk";
                type = "file";
                disableDeletion = true;
                allowUiUpdates = false;
                updateIntervalSeconds = 86400;
                options.path =
                  pkgs.fetchFromGitHub {
                    owner = "rfmoz";
                    repo = "grafana-dashboards";
                    rev = "master";
                    sha256 = "sha256-xRR2VQ/XkqSfhcON+idYgNQIZ5Sn1pSfYtqSdHKD4Bs=";
                  }
                  + "/prometheus/node-exporter-full.json";
              }
              {
                name = "restic";
                orgId = 1;
                folder = "Restic";
                folderUid = "cejvfx2zfaqkgd";
                type = "file";
                disableDeletion = true;
                allowUiUpdates = false;
                updateIntervalSeconds = 86400;
                options.path =
                  let
                    originalDashboard =
                      pkgs.fetchFromGitHub {
                        owner = "ngosang";
                        repo = "restic-exporter";
                        rev = "main";
                        sha256 = "sha256-F0lNjAjtcOihSIJLux6Gyig7UU9Tl+PcZ0xQ/KryCpQ=";
                      }
                      + "/grafana/grafana_dashboard.json";
                    modifiedDashboard =
                      pkgs.runCommand "modified-restic-dashboard.json"
                        {
                          buildInputs = [ pkgs.jq ];
                        }
                        ''
                          jq '.templating.list = [
                            {
                              "current": {
                                "text": "Prometheus",
                                "value": "PBFA97CFB590B2093"
                              },
                              "label": "Prometheus",
                              "name": "DS_PROMETHEUS",
                              "options": [],
                              "query": "prometheus",
                              "refresh": 1,
                              "regex": "",
                              "type": "datasource"
                            }
                          ]' ${originalDashboard} > $out
                        '';
                  in
                  modifiedDashboard;
              }
            ];
          };
          datasources = {
            settings = {
              datasources = [
                {
                  name = "Prometheus";
                  type = "prometheus";
                  access = "proxy";
                  url = "http://127.0.0.1:${toString config.services.prometheus.port}";
                  editable = false;
                }
                {
                  name = "Tempo";
                  type = "tempo";
                  uid = "tempo";
                  access = "proxy";
                  url = "http://127.0.0.1:${toString config.services.tempo.settings.server.http_listen_port}";
                  editable = false;
                }
              ];
            };
          };
          alerting = {
            contactPoints.settings.contactPoints = [
              {
                name = "ntfy";
                orgId = 1;
                receivers = [
                  {
                    uid = "ntfy-webhook";
                    type = "webhook";
                    settings = {
                      url = "http://localhost:8000";
                      httpMethod = "POST";
                      username = "admin";
                      inherit (inputs.nix-secrets.grafanaToNtfy) password;
                    };
                  }
                ];
              }
            ];
            policies.settings.policies = [
              {
                orgId = 1;
                receiver = "ntfy";
              }
            ];
            rules.path = ./alerts.yaml;
          };
        };
      };
    };
  };
}
