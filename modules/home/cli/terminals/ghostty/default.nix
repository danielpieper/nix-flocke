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

      settings = {
        font-family = "${config.stylix.fonts.monospace.name}";
        command = "fish";
        gtk-titlebar = false;
        gtk-single-instance = true;
        font-size = 12;
        confirm-close-surface = false;
        copy-on-select = true;
      };
    };
  };
}
