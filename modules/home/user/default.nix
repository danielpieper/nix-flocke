{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.flocke.user;
in
{
  options.flocke.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";
    home = mkOpt (types.nullOr types.str) "/home/${cfg.name}" "The user's home directory.";
    name = mkOpt (types.nullOr types.str) config.snowfallorg.user.name "The user account.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "flocke.user.name must be set";
        }
      ];

      home = {
        homeDirectory = mkDefault cfg.home;
        username = mkDefault cfg.name;
      };
    }
  ]);
}
