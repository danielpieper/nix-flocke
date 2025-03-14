{
  config,
  lib,
  pkgs,
  ...
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
            DOMAIN = "forgejo.homelab.daniel-pieper.com";
            # You need to specify this to remove the port from URLs in the web UI.
            ROOT_URL = "https://forgejo.homelab.daniel-pieper.com/";
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
            SMTP_ADDR = "smtp.eu.mailgun.org";
            SMTP_PORT = 587;
            FROM = "homelab@daniel-pieper.com";
            USER = "postmaster@mail.daniel-pieper.com";
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
                rule = "Host(`forgejo.homelab.daniel-pieper.com`)";
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
        user = "daniel"; # Note, Forgejo doesn't allow creation of an account named "admin"
      in
      ''
        ${adminCmd} create --admin --email "git@daniel-pieper.com" --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
        ## uncomment this line to change an admin user which was already created
        # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
      '';

    sops.secrets = {
      forgejo-mailer-password = {
        sopsFile = ../secrets.yaml;
        owner = config.services.forgejo.user;
      };
      forgejo-admin-password = {
        sopsFile = ../secrets.yaml;
        owner = config.services.forgejo.user;
      };
    };
  };
}
