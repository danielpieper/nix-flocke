{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.terminals.ghostty;
in
{
  options.cli.terminals.ghostty = with types; {
    enable = mkBoolOpt false "enable ghostty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;

      enableFishIntegration = true;
      enableBashIntegration = false;
      enableZshIntegration = false;

      settings = {
        command = "fish";
        initial-command = "fish";
        font-family = "MonoLisa Nerd Font";
        font-size = 12;
      };
    };
  };
}
