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

      settings = {
        theme = "catppuccin-mocha";
        font-family = "${config.stylix.fonts.monospace.name}";
        command = "fish";
        gtk-titlebar = false;
        font-size = 12;
        confirm-close-surface = false;
      };
    };
  };
}
