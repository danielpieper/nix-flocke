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
    enable = mkEnableOption "Enable The monitoring stack(loki, prometheus, grafana)";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      grafana_oauth2_client_id.owner = "grafana";
      grafana_oauth2_client_secret.owner = "grafana";
    };

    services = {
      traefik = {
        dynamicConfigOptions = {
          http = {
            services = {
              prometheus.loadBalancer.servers = [
                {
                  url = "http://localhost:3020";
                }
              ];
              grafana.loadBalancer.servers = [
                {
                  url = "http://localhost:3010";
                }
              ];
              promtail.loadBalancer.servers = [
                {
                  url = "http://localhost:3031";
                }
              ];
            };

            routers = {
              prometheus = {
                entryPoints = [ "websecure" ];
                rule = "Host(`prometheus.homelab.${inputs.nix-secrets.domain}`)";
                service = "prometheus";
              };
              grafana = {
                entryPoints = [ "websecure" ];
                rule = "Host(`grafana.homelab.${inputs.nix-secrets.domain}`)";
                service = "grafana";
              };
              promtail = {
                entryPoints = [ "websecure" ];
                rule = "Host(`promtail.homelab.${inputs.nix-secrets.domain}`)";
                service = "promtail";
              };
            };
          };
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
                  "jarvis:${toString config.services.prometheus.exporters.node.port}"
                ];
              }
            ];
          }
        ];
      };

      loki = {
        enable = true;
        configuration = {
          server = {
            http_listen_port = 3030;
            log_level = "warn";
          };
          auth_enabled = false;
          ingester = {
            lifecycler = {
              ring = {
                kvstore = {
                  store = "inmemory";
                };
                replication_factor = 1;
              };
            };
            chunk_idle_period = "5m";
            chunk_retain_period = "30s";
          };
          schema_config = {
            configs = [
              {
                from = "2020-10-24";
                store = "boltdb-shipper";
                object_store = "filesystem";
                schema = "v13";
                index = {
                  prefix = "index_";
                  period = "24h";
                };
              }
            ];
          };
          storage_config = {
            boltdb_shipper = {
              active_index_directory = "/var/lib/loki/index";
              cache_location = "/var/lib/loki/cache";
            };
            filesystem = {
              directory = "/var/lib/loki/chunks";
            };
          };
          limits_config = {
            reject_old_samples = true;
            reject_old_samples_max_age = "168h";
            allow_structured_metadata = false;
          };
          compactor = {
            working_directory = "/var/lib/loki/compactor";
          };
        };
      };

      # TODO: replace with grafana alloy https://github.com/grafana/alloy
      promtail = {
        enable = true;
        configuration = {
          server = {
            http_listen_port = 3031;
            grpc_listen_port = 0;
          };
          positions = {
            filename = "/tmp/positions.yaml";
          };
          clients = [
            {
              url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
            }
          ];
          scrape_configs = [
            {
              job_name = "journal";
              journal = {
                max_age = "12h";
                labels = {
                  job = "systemd-journal";
                  # TODO: do not hardcode
                  host = "hal";
                };
              };
              relabel_configs = [
                {
                  source_labels = [ "__journal__systemd_unit" ];
                  target_label = "unit";
                }
              ];
            }
          ];
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
            root_url = "https://grafana.homelab.${inputs.nix-secrets.domain}";
          };

          "auth" = {
            signout_redirect_url = "https://authentik.homelab.${inputs.nix-secrets.domain}/application/o/grafana/end-session/";
            oauth_auto_login = true;
          };

          "auth.generic_oauth" = {
            enabled = true;
            client_id = "$__file{${config.sops.secrets.grafana_oauth2_client_id.path}}";
            client_secret = "$__file{${config.sops.secrets.grafana_oauth2_client_secret.path}}";
            scopes = "openid profile email";
            auth_url = "https://authentik.homelab.${inputs.nix-secrets.domain}/application/o/authorize/";
            token_url = "https://authentik.homelab.${inputs.nix-secrets.domain}/application/o/token/";
            api_url = "https://authentik.homelab.${inputs.nix-secrets.domain}/application/o/userinfo/";
            role_attribute_path = "contains(groups, 'Grafana Admins') && 'Admin' || contains(groups, 'Grafana Editors') && 'Editor' || 'Viewer'";
          };
          database = {
            host = "/run/postgresql";
            user = "grafana";
            name = "grafana";
            type = "postgres";
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
                    sha256 = "sha256-ZkVijMRCd87sLckqezPh1wHfuiibExVhatA1AqRiKHc=";
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
                        sha256 = "sha256-y4bVamL+xnofM/XkBEf5oiX1Ji7rO1M6yoxZ1FJVeuE=";
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
                  name = "Loki";
                  type = "loki";
                  access = "proxy";
                  url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
                  editable = false;
                }
              ];
            };
          };
          alerting = {
            # contactPoints.settings.contactPoints = [
            #   {
            #     name = "Gotify";
            #     orgId = 1;
            #     receivers = [
            #       {
            #         inherit (inputs.nix-secrets.gotify) uid;
            #         type = "webhook";
            #         settings = {
            #           # TODO: provision gotify token and add here
            #           url =
            #             with config.services.gotify;
            #             "http://localhost:${environment.GOTIFY_SERVER_PORT}/message?token=";
            #           httpMethod = "POST";
            #         };
            #       }
            #     ];
            #   }
            # ];
            # https://gist.github.com/krisek/62a98e2645af5dce169a7b506e999cd8
            rules.path = ./alerts.yaml;
            # contactPoints.settings.deleteContactPoints = [
            #   {
            #     orgId = 1;
            #     uid = "";
            #   }
            # ];
            # rules.settings.deleteRules = [
            #   {
            #     orgId = 1;
            #     uid = "";
            #   }
            # ];
          };
        };
      };
    };
  };
}
