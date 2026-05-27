{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.keto;
  yamlFormat = pkgs.formats.yaml { };
  # The OPL namespace model ships with the projectz repo; reuse it directly so
  # the relation model stays in lockstep with the app that depends on it.
  namespacesFile = "${inputs.projectz}/build/docker/keto/namespaces.keto.ts";
  ketoConfig = {
    # keto wants a `version` field; track the packaged binary (e.g. "v26.2.0").
    version = "v${cfg.package.version}";
  }
  // cfg.settings
  // {
    namespaces.location = "file://${namespacesFile}";
  };
  ketoConfigFile = yamlFormat.generate "keto.yaml" ketoConfig;
in
{
  options.services.flocke.keto = {
    enable = mkEnableOption "Ory Keto - an open source access-control (authorization) server";

    package = mkOption {
      type = types.package;
      default = pkgs.keto;
      defaultText = "pkgs.keto";
      description = "The package implementing keto";
    };

    settings = mkOption {
      inherit (yamlFormat) type;
      default = {
        serve = {
          read.host = "127.0.0.1";
          write.host = "127.0.0.1";
          metrics.host = "127.0.0.1";
        };
      };
      description = ''
        Configuration for Keto. See
        <https://www.ory.sh/docs/keto/reference/configuration>.
        `namespaces.location` is set automatically from the projectz OPL file.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.keto =
      let
        keto = "${cfg.package}/bin/keto";
      in
      {
        description = "Ory Keto - access control server";
        wantedBy = [ "multi-user.target" ];
        after = [
          "network.target"
          "postgresql.service"
        ];
        requires = [ "postgresql.service" ];
        # apply relation-tuple schema migrations against the keto database
        preStart = "${keto} migrate up -y -c ${ketoConfigFile}";
        serviceConfig = {
          ExecStart = "${keto} serve -c ${ketoConfigFile}";
          Restart = "always";
          RestartSec = "5s";
          User = "keto";
          Group = "keto";
        };
      };

    users.users.keto = {
      description = "Keto service user";
      createHome = false;
      isSystemUser = true;
      group = "keto";
    };
    users.groups.keto = { };
  };
}
