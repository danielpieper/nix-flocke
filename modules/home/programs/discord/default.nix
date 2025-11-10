{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.programs.flocke.discord;
in
{
  options.programs.flocke.discord = with types; {
    enable = mkBoolOpt false "Whether or not to manage discord";
  };

  config = mkIf cfg.enable {
    xdg.configFile."BetterDiscord/data/stable/custom.css" = {
      source = ./custom.css;
    };
    home.packages = with pkgs; [ goofcord ];
  };
}
