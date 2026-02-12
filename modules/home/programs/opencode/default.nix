{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.programs.flocke.opencode;
in
{
  options.programs.flocke.opencode = with types; {
    enable = mkBoolOpt false "Enable opencode CLI coding agent";

    ollamaHost = mkOption {
      type = types.str;
      default = "http://localhost:11434";
      description = "Ollama server endpoint";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.llm-agents.opencode
    ];

    home.sessionVariables = {
      OLLAMA_HOST = cfg.ollamaHost;
    };
  };
}
