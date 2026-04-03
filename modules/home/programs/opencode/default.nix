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

    baseUrl = mkOption {
      type = types.str;
      default = "http://localhost:11434/v1";
      description = "OpenAI-compatible API endpoint";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.llm-agents.opencode
    ];

    sops.secrets.openrouter_api_key = { };

    home.sessionVariables = {
      OPENAI_BASE_URL = cfg.baseUrl;
    };

    programs.fish.interactiveShellInit = ''
      if test -f ${config.sops.secrets.openrouter_api_key.path}
        set -gx OPENROUTER_API_KEY (cat ${config.sops.secrets.openrouter_api_key.path})
      end
    '';
  };
}
