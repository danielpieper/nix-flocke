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

    model = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Model to use (e.g. qwen3.5-27b-opus)";
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

    xdg.configFile."opencode/opencode.json" = {
      force = true;
      text = builtins.toJSON (
        {
          "$schema" = "https://opencode.ai/config.json";
          provider = {
            llama-cpp = {
              name = "llama-cpp";
              npm = "@ai-sdk/openai-compatible";
              options = {
                baseURL = cfg.baseUrl;
              };
              models = lib.optionalAttrs (cfg.model != null) {
                "${cfg.model}" = {
                  name = "${cfg.model} (local)";
                };
              };
            };
          };
        }
        // lib.optionalAttrs (cfg.model != null) {
          model = "llama-cpp/${cfg.model}";
        }
      );
    };

    programs.fish.interactiveShellInit = ''
      if test -f ${config.sops.secrets.openrouter_api_key.path}
        set -gx OPENROUTER_API_KEY (cat ${config.sops.secrets.openrouter_api_key.path})
      end
    '';
  };
}
