{ config
, lib
, inputs
, pkgs
, ...
}:
with lib;
let
  cfg = config.services.flocke.forgejo;
in
{
  imports = [
    ./runner.nix
    ./dump.nix
  ];

  # see https://docs.goauthentik.io/integrations/services/gitea/
  options.services.flocke.forgejo = {
    enable = mkEnableOption "Enable Forgejo";
  };

  config = mkIf cfg.enable {
    services = {
      forgejo = {
        enable = true;
        package = pkgs.forgejo;
        database = {
          type = "postgres";
          socket = "/run/postgresql";
          user = "forgejo";
          name = "forgejo";
        };
        # Enable support for Git Large File Storage
        # lfs.enable = true;
        settings = {
          server = {
            DOMAIN = "forgejo.homelab.${inputs.nix-secrets.domain}";
            # You need to specify this to remove the port from URLs in the web UI.
            ROOT_URL = "https://forgejo.homelab.${inputs.nix-secrets.domain}/";
            HTTP_ADDR = "127.0.0.1";
            HTTP_PORT = 3083;
          };
          # You can temporarily allow registration to create an admin user.
          service.DISABLE_REGISTRATION = true;
          # Add support for actions, based on act: https://github.com/nektos/act
          actions = {
            ENABLED = true;
            DEFAULT_ACTIONS_URL = "github";
          };
          # Sending emails is completely optional
          # You can send a test email from the web UI at:
          # Profile Picture > Site Administration > Configuration >  Mailer Configuration
          mailer = {
            ENABLED = true;
            PROTOCOL = "smtps+starttls";
            SMTP_ADDR = inputs.nix-secrets.mailgun.host;
            SMTP_PORT = inputs.nix-secrets.mailgun.port;
            FROM = inputs.nix-secrets.mailgun.fromEmail;
            USER = inputs.nix-secrets.mailgun.username;
          };
          log = {
            LEVEL = "Warn";
          };
        };
        secrets = {
          mailer = {
            PASSWD = config.sops.secrets.forgejo-mailer-password.path;
          };
        };
      };

      postgresql = {
        ensureDatabases = [ "forgejo" ];
        ensureUsers = [
          {
            name = "forgejo";
            ensureDBOwnership = true;
          }
        ];
      };

      traefik = {
        dynamicConfigOptions = {
          http = {
            services = {
              forgejo.loadBalancer.servers = [
                {
                  url = "http://localhost:3083";
                }
              ];
            };

            routers = {
              forgejo = {
                entryPoints = [ "websecure" ];
                rule = "Host(`forgejo.homelab.${inputs.nix-secrets.domain}`)";
                service = "forgejo";
                tls.certResolver = "letsencrypt";
              };
            };
          };
        };
      };
    };

    systemd.services.forgejo.preStart =
      let
        adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
        pwd = config.sops.secrets.forgejo-admin-password;
        user = inputs.nix-secrets.forgejo.user; # Note, Forgejo doesn't allow creation of an account named "admin"
      in
      ''
        ${adminCmd} create --admin --email "${inputs.nix-secrets.forgejo.email}" --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
        ## uncomment this line to change an admin user which was already created
        # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
      '';

    sops.secrets = {
      forgejo-mailer-password.owner = config.services.forgejo.user;
      forgejo-admin-password.owner = config.services.forgejo.user;
    };
  };
}
