{
  lib,
  config,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.shells.zsh;
in
{
  options.cli.shells.zsh = with types; {
    enable = mkBoolOpt false "enable zsh shell";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
    };
  };
}
