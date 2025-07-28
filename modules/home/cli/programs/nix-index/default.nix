{
  lib,
  config,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.programs.nix-index;
in
{
  options.cli.programs.nix-index = with types; {
    enable = mkBoolOpt false "Whether or not to nix index";
  };

  imports = with inputs; [
    nix-index-database.homeModules.nix-index
  ];

  config = mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
      enableBashIntegration = true;
    };
    programs.nix-index-database.comma.enable = true;
  };
}
