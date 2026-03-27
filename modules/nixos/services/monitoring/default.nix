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
    sops.secrets = {
      grafana_oauth2_client_id.owner = "grafana";
      grafana_oauth2_client_secret.owner = "grafana";
      grafana_secret_key.owner = "grafana";
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
                    sha256 = "sha256-FIOeom1pAuBjD/o3ScEe/QZn/Z8R7eADYXTDZIqlmnM=";
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
