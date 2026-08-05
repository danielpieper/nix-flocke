{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.programs.delta;
in
{
  options.cli.programs.delta = with types; {
    enable = mkBoolOpt false "Whether or not to enable delta";
  };

  config = mkIf cfg.enable {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        dark = "true";
        side-by-side = "false"; # https://github.com/dandavison/delta/issues/359
        line-numbers = "true";
        navigate = "true";
        # Atom One Dark port, to match neovim's onedark_vivid (onedarkpro.nvim)
        syntax-theme = "TwoDark";
        zero-style = "dim syntax";

        # +/- line backgrounds are left at delta's defaults; the Catppuccin
        # tints were too low-contrast to tell additions from removals.
        line-numbers-minus-style = "bold #f38ba8";
        line-numbers-plus-style = "bold #a6e3a1";
        line-numbers-zero-style = "#6c7086";
      };
    };
  };
}
