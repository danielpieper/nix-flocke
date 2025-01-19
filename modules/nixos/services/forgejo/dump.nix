{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.forgejo;
in
{
  options.services.flocke.forgejo = {
    enable-dump = mkEnableOption "Enable Forgejo daily dump";
  };

  config = mkIf cfg.enable-dump {
    services = {
      forgejo.dump = {
        enable = true;
        backupDir = "/mnt/nas/5.5tb/forgejo";
        file = "forgejo-dump";
      };
      flocke.nfs.enable = true;
    };
  };
}
