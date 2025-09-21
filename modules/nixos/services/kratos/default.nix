{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.kratos;
  yamlFormat = pkgs.formats.yaml { };
  jsonFormat = pkgs.formats.json { };
  identitySchemaFile = jsonFormat.generate "identity.schema.json" cfg.identitySchema;
  kratosConfig = cfg.settings // {
    dsn = "memory";
    identity = {
      default_schema_id = "default";
      schemas = [
        {
          id = "default";
          url = "file://${identitySchemaFile}";
        }
      ];
    };
  };
  kratosConfigFile = yamlFormat.generate "kratos.yaml" kratosConfig;
in
{
  options.services.flocke.kratos = {
    enable = mkEnableOption "Ory Kratos - An API-first Identity and User Management system";

    package = mkOption {
      type = types.package;
      default = pkgs.kratos;
      defaultText = "pkgs.kratos";
      description = ''
        The package implementing kratos
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/root/example.env";
      description = lib.mdDoc ''
        Environment file to inject e.g. secrets into the configuration.
      '';
    };

    settings = mkOption {
      inherit (yamlFormat) type;
      default = {
        version = "v1.31.0";
        dsn = "memory";
        serve = {
          public = {
            base_url = "http://127.0.0.1:4433/";
          };
        };
      };
      example = {
        version = "v1.31.0";
        dsn = "memory";
        serve = {
          public = {
            base_url = "http://127.0.0.1:4433/";
          };
        };
      };
      description = lib.mdDoc ''
        Configuration to use for Kratos. See
        <https://www.ory.sh/docs/kratos/configuring>
        for available options.
      '';
    };

    identitySchema = mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = {
        "$schema" = "http://json-schema.org/draft-07/schema#";
        title = "Person";
        type = "object";
        properties = { };
        description = ''
          The default identity schema
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.kratos =
      let
        kratos = "${cfg.package}/bin/kratos";
      in
      mkMerge [
        {
          description = "Ory Kratos - An API-first Identity and User Management system";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          serviceConfig = {
            EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;
            ExecStart = "${kratos} -c ${kratosConfigFile} serve";
            Restart = "always";
            User = "kratos";
            Group = "kratos";
          };
        }
        (mkIf (cfg.settings.dsn != "memory") {
          preStart = "${kratos} -c ${kratosConfigFile} migrate sql -y ${cfg.settings.dsn}";
        })
      ];

    users.users.kratos = {
      description = "Kratos service user";
      createHome = false;
      isSystemUser = true;
      group = "kratos";
    };
    users.groups.kratos = { };
  };
}
