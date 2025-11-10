{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.postgresql;
in
{
  options.services.flocke.postgresql = {
    enable = mkEnableOption "Enable postgresql";
  };

  config = mkIf cfg.enable {
    services = {
      postgresql = {
        enable = true;
      };
      postgresqlBackup = {
        # TODO: postgres backup
        enable = false;
        location = "/mnt/share/postgresql";
        backupAll = true;
        startAt = "*-*-* 10:00:00";
      };
    };

    # https://nixos.org/manual/nixos/stable/#module-services-postgres-upgrading
    # environment.systemPackages = [
    #   (
    #     let
    #       # XXX specify the postgresql package you'd like to upgrade to.
    #       # Do not forget to list the extensions you need.
    #       # newPostgres = pkgs.postgresql_13.withPackages (pp: [
    #       # pp.plv8
    #       # ]);
    #       newPostgres = pkgs.postgresql_17;
    #       cfg = config.services.postgresql;
    #     in
    #     pkgs.writeScriptBin "upgrade-pg-cluster" ''
    #       set -eux
    #       # XXX it's perhaps advisable to stop all services that depend on postgresql
    #       systemctl stop postgresql
    #
    #       export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"
    #
    #       export NEWBIN="${newPostgres}/bin"
    #
    #       export OLDDATA="${cfg.dataDir}"
    #       export OLDBIN="${cfg.package}/bin"
    #
    #       install -d -m 0700 -o postgres -g postgres "$NEWDATA"
    #       cd "$NEWDATA"
    #       sudo -u postgres $NEWBIN/initdb -D "$NEWDATA" ${lib.escapeShellArgs cfg.initdbArgs}
    #
    #       sudo -u postgres $NEWBIN/pg_upgrade \
    #         --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
    #         --old-bindir $OLDBIN --new-bindir $NEWBIN \
    #         "$@"
    #     ''
    #   )
    # ];
  };
}
