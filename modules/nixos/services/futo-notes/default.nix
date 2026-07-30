{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.futo-notes;
  domain = inputs.nix-secrets.homelabDomain;
  port = 3005;
  user = "futo-notes";
in
{
  options.services.flocke.futo-notes = {
    enable = mkEnableOption "Enable the FUTO Notes sync server";
  };

  config = mkIf cfg.enable {
    # FUTO_NOTES_PASSWORD=<shared sync password>
    # The server has no OIDC support and the native clients cannot follow a
    # browser redirect, so this password is the only gate in front of Authelia's
    # peers here. Note bodies are end-to-end encrypted by the client, so the
    # server only ever stores opaque blobs.
    sops.secrets."futo-notes_env" = { };

    users = {
      users.${user} = {
        isSystemUser = true;
        group = user;
      };
      groups.${user} = { };
    };

    services = {
      postgresql = {
        # Database name must match the role name for ensureDBOwnership.
        ensureDatabases = [ user ];
        ensureUsers = [
          {
            name = user;
            ensureDBOwnership = true;
          }
        ];
      };

      caddy.virtualHosts."notes.${domain}" = {
        useACMEHost = domain;
        extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
      };
    };

    systemd.services.futo-notes = {
      description = "FUTO Notes sync server";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "postgresql.target"
      ];
      requires = [ "postgresql.target" ];

      environment = {
        # Peer auth over the unix socket; the system user matches the role name.
        DATABASE_URL = "postgres://${user}@/${user}?host=/run/postgresql";
        PORT = toString port;
        BLOB_DIR = "/var/lib/futo-notes/blobs";
        AUTH_MODE = "password";
        # Caddy sets X-Forwarded-For, so the login rate limiter keys on the real
        # client instead of lumping every request onto the proxy's address.
        TRUST_PROXY = "true";
      };

      serviceConfig = {
        ExecStart = getExe pkgs.flocke.futo-notes-server;
        EnvironmentFile = config.sops.secrets."futo-notes_env".path;
        User = user;
        Group = user;
        # The blob store mkdir -p's on write, but the maintenance loop scans the
        # directory at startup, so create it up front.
        StateDirectory = [
          "futo-notes"
          "futo-notes/blobs"
        ];
        StateDirectoryMode = "0700";
        Restart = "on-failure";
        RestartSec = 5;

        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
      };
    };
  };
}
