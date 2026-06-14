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
        syntax-theme = "Monokai Extended";
        zero-style = "dim syntax";

        # Catppuccin Mocha diff styling (upstream catppuccin/delta tints)
        minus-style = "syntax #34293a";
        minus-emph-style = "bold syntax #53394c";
        plus-style = "syntax #2c3239";
        plus-emph-style = "bold syntax #404f4a";
        line-numbers-minus-style = "bold #f38ba8";
        line-numbers-plus-style = "bold #a6e3a1";
        line-numbers-zero-style = "#6c7086";
      };
    };
  };
}
