{
  inputs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.projectz;
  projectzDomain = inputs.nix-secrets.projectzDomain;
in
{
  imports = [ inputs.projectz.nixosModules.default ];

  options.services.flocke.projectz = {
    enable = mkEnableOption "Enable projectz (multi-tenant HR application)";
  };

  config = mkIf cfg.enable {
    # Secrets stay out of the nix store: API key + mail password (projectz_env)
    # and Kratos cookie/cipher/SMTP secrets (kratos_env) are injected as env files.
    sops.secrets = {
      projectz_env = { };
      kratos_env = { };
    };

    services = {
      projectz = {
        enable = true;
        environment = inputs.nix-secrets.projectz.environment // {
          PROJECTZ_HTTP_ADDR = ":8083";
        };
        environmentFile = config.sops.secrets.projectz_env.path;
      };

      # peer auth: each service runs as a system user matching its postgres role.
      # sudo -u postgres psql
      postgresql = {
        ensureDatabases = [
          "projectz"
          "kratos"
          "keto"
        ];
        ensureUsers = [
          {
            name = "projectz";
            ensureDBOwnership = true;
          }
          {
            name = "kratos";
            ensureDBOwnership = true;
          }
          {
            name = "keto";
            ensureDBOwnership = true;
          }
        ];
      };

      flocke = {
        postgresql.enable = true;

        kratos = {
          enable = true;
          inherit (inputs.nix-secrets.projectz.kratos) settings identitySchema;
          environmentFile = config.sops.secrets.kratos_env.path;
        };

        keto = {
          enable = true;
          settings = {
            dsn = "postgres://keto@/keto?host=/run/postgresql&sslmode=disable";
            serve = {
              read = {
                host = "127.0.0.1";
                port = 4466;
              };
              write = {
                host = "127.0.0.1";
                port = 4467;
              };
              metrics.host = "127.0.0.1";
            };
            log = {
              level = "info";
              format = "text";
            };
          };
        };
      };

      # Cloudflare terminates TLS at the edge and cloudflared dials out, so the
      # origin is plain HTTP. One block matches the apex, the auth host and every
      # tenant subdomain; the app dispatches by Host. `http://` keeps Caddy from
      # attempting ACME and outranks the global http:// redirect in the caddy module.
      caddy.virtualHosts."http://${projectzDomain}, http://*.${projectzDomain}".extraConfig = ''
        reverse_proxy localhost:8083
      '';
    };

    # the app must come up after its dependencies (the upstream module already
    # orders after postgresql + kratos; add keto and make the deps hard requirements).
    systemd.services.projectz = {
      after = [ "keto.service" ];
      requires = [
        "postgresql.service"
        "kratos.service"
        "keto.service"
      ];
    };

    # document storage (fs backend, PROJECTZ_STORAGE_FS_ROOT); persisted via /var/lib.
    systemd.tmpfiles.rules = [
      "d /var/lib/projectz 0750 projectz projectz -"
      "d /var/lib/projectz/storage 0750 projectz projectz -"
    ];
  };
}
