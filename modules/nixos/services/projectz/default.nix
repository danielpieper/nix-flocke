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
            # OTLP traces → local otelcol on ava (HTTP 4318) → Tempo on jarvis.
            # Keto spans every permission check; 1.0 sampling is fine pre-launch.
            tracing = {
              provider = "otel";
              service_name = "Ory Keto";
              deployment_environment = "production";
              providers.otlp = {
                server_url = "127.0.0.1:4318";
                insecure = true;
                sampling.sampling_ratio = 1.0;
              };
            };
          };
        };
      };

      # Cloudflare terminates TLS at the edge and cloudflared dials out, so the
      # origin is plain HTTP. The apex + tenant subdomains all go to the app,
      # which dispatches by Host. `http://` keeps Caddy from attempting ACME and
      # outranks the global http:// redirect in the caddy module.
      caddy.virtualHosts = {
        # The auth host is shared between the app (login/registration UI, served
        # by GET routes) and Kratos's public API. Kratos's browser endpoints —
        # the form submits behind ui.action, logout, webauthn — must reach Kratos
        # directly on :4433; otherwise the native form POST falls through to the
        # app, whose text/event-stream guard 406s every non-SSE mutation. An
        # exact host beats the wildcard below, so this block owns auth.${domain}.
        "http://auth.${projectzDomain}".extraConfig = ''
          @kratos path /self-service/* /.well-known/ory/* /schemas/* /sessions/*
          reverse_proxy @kratos localhost:4433
          reverse_proxy localhost:8083
        '';
        "http://${projectzDomain}, http://*.${projectzDomain}".extraConfig = ''
          reverse_proxy localhost:8083
        '';
      };
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
