{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.authelia;
  inherit (inputs.nix-secrets) homelabDomain tailscaleDomain;
  sunshineHost = inputs.nix-secrets.networking.localHosts.sunshine;
  domain = homelabDomain;
in
{
  options.services.flocke.authelia = {
    enable = mkEnableOption "Enable Authelia SSO";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      authelia-jwt-secret.owner = "authelia-main";
      authelia-storage-encryption-key.owner = "authelia-main";
      authelia-session-secret.owner = "authelia-main";
      authelia-oidc-hmac-secret.owner = "authelia-main";
      authelia-oidc-jwks-key.owner = "authelia-main";
      authelia-users.owner = "authelia-main";
      authelia-smtp-password.owner = "authelia-main";
    };

    services = {
      authelia.instances.main = {
        enable = true;
        secrets = {
          jwtSecretFile = config.sops.secrets.authelia-jwt-secret.path;
          storageEncryptionKeyFile = config.sops.secrets.authelia-storage-encryption-key.path;
          oidcIssuerPrivateKeyFile = config.sops.secrets.authelia-oidc-jwks-key.path;
          oidcHmacSecretFile = config.sops.secrets.authelia-oidc-hmac-secret.path;
        };
        environmentVariables = {
          AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = config.sops.secrets.authelia-smtp-password.path;
        };
        settings = {
          theme = "auto";
          default_2fa_method = "totp";

          server.address = "tcp://127.0.0.1:9091/";

          log = {
            level = "info";
            format = "text";
          };

          authentication_backend.file = {
            inherit (config.sops.secrets.authelia-users) path;
            watch = false;
            password.algorithm = "argon2";
          };

          session.cookies = [
            {
              inherit domain;
              authelia_url = "https://auth.${domain}";
            }
          ];

          storage.postgres = {
            address = "unix:///run/postgresql";
            database = "authelia";
            username = "authelia";
          };

          access_control.default_policy = "one_factor";

          identity_providers.oidc.clients = [
            {
              client_id = "grafana";
              client_name = "Grafana";
              client_secret = inputs.nix-secrets.authelia.oidcClients.grafana.clientSecretHash;
              authorization_policy = "one_factor";
              redirect_uris = [ "https://grafana.${domain}/login/generic_oauth" ];
              scopes = [
                "openid"
                "profile"
                "email"
                "groups"
              ];
              token_endpoint_auth_method = "client_secret_basic";
            }
            {
              client_id = "forgejo";
              client_name = "Forgejo";
              client_secret = inputs.nix-secrets.authelia.oidcClients.forgejo.clientSecretHash;
              authorization_policy = "one_factor";
              redirect_uris = [ "https://forgejo.${domain}/user/oauth2/authelia/callback" ];
              scopes = [
                "openid"
                "profile"
                "email"
                "groups"
              ];
              token_endpoint_auth_method = "client_secret_basic";
            }
            {
              client_id = "miniflux";
              client_name = "Miniflux";
              client_secret = inputs.nix-secrets.authelia.oidcClients.miniflux.clientSecretHash;
              authorization_policy = "one_factor";
              redirect_uris = [ "https://miniflux.${domain}/oauth2/oidc/callback" ];
              scopes = [
                "openid"
                "profile"
                "email"
              ];
              token_endpoint_auth_method = "client_secret_basic";
            }
            {
              client_id = "mealie";
              client_name = "Mealie";
              client_secret = inputs.nix-secrets.authelia.oidcClients.mealie.clientSecretHash;
              authorization_policy = "one_factor";
              redirect_uris = [ "https://mealie.${domain}/login" ];
              scopes = [
                "openid"
                "profile"
                "email"
                "groups"
              ];
              token_endpoint_auth_method = "client_secret_basic";
            }
            {
              client_id = "immich";
              client_name = "Immich";
              client_secret = inputs.nix-secrets.authelia.oidcClients.immich.clientSecretHash;
              authorization_policy = "one_factor";
              redirect_uris = [
                "https://immich.${domain}/auth/login"
                "https://immich.${domain}/user-settings"
                "app.immich:///oauth-callback"
              ];
              scopes = [
                "openid"
                "profile"
                "email"
              ];
              token_endpoint_auth_method = "client_secret_post";
            }
            {
              client_id = "paperless";
              client_name = "Paperless";
              client_secret = inputs.nix-secrets.authelia.oidcClients.paperless.clientSecretHash;
              authorization_policy = "one_factor";
              redirect_uris = [ "https://paperless.${domain}/accounts/oidc/authelia/login/callback/" ];
              scopes = [
                "openid"
                "profile"
                "email"
              ];
              token_endpoint_auth_method = "client_secret_post";
            }
            {
              client_id = "trilium";
              client_name = "Trilium";
              client_secret = inputs.nix-secrets.authelia.oidcClients.trilium.clientSecretHash;
              authorization_policy = "one_factor";
              redirect_uris = [ "https://trilium.${domain}/callback" ];
              scopes = [
                "openid"
                "profile"
                "email"
              ];
              token_endpoint_auth_method = "client_secret_basic";
            }
          ];

          notifier.smtp = {
            address = "smtp://${inputs.nix-secrets.mailgun.host}:${toString inputs.nix-secrets.mailgun.port}";
            inherit (inputs.nix-secrets.mailgun) username;
            sender = "Authelia <${inputs.nix-secrets.mailgun.from}>";
          };

        };
      };

      postgresql = {
        ensureDatabases = [ "authelia" ];
        ensureUsers = [
          {
            name = "authelia";
            ensureDBOwnership = true;
          }
        ];
        identMap = ''
          authelia-map authelia-main authelia
        '';
        authentication = lib.mkAfter ''
          local authelia authelia peer map=authelia-map
        '';
      };

      caddy.virtualHosts = {
        "auth.${domain}" = {
          useACMEHost = domain;
          extraConfig = "reverse_proxy 127.0.0.1:9091";
        };
        "${domain}" = {
          useACMEHost = domain;
          extraConfig = ''
            header Content-Type text/html
            respond `${
              builtins.replaceStrings
                [ "__DOMAIN__" "__TAILSCALE_DOMAIN__" "__SUNSHINE_HOST__" ]
                [ domain tailscaleDomain sunshineHost ]
                (builtins.readFile ./dashboard.html)
            }`
          '';
        };
      };
    };
  };
}
