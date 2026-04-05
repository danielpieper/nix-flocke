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

    provider = mkOption {
      type = types.enum [
        "llama-cpp"
        "lmstudio"
        "ollama"
      ];
      default = "llama-cpp";
      description = "Which local provider to use";
    };

    baseUrl = mkOption {
      type = types.str;
      default = "http://localhost:11434/v1";
      description = "OpenAI-compatible API endpoint";
    };

    model = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default model to use";
    };

    extraModels = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional models to make available";
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

    xdg.configFile."opencode/opencode.json" =
      let
        providerConfigs = {
          llama-cpp = {
            name = "llama-cpp";
            npm = "@ai-sdk/openai-compatible";
            options.baseURL = cfg.baseUrl;
          };
          lmstudio = {
            name = "LM Studio (local)";
            npm = "@ai-sdk/openai-compatible";
            options.baseURL = cfg.baseUrl;
          };
          ollama = {
            name = "Ollama (local)";
            npm = "@ai-sdk/openai-compatible";
            options.baseURL = cfg.baseUrl;
          };
        };
        allModels = (lib.optional (cfg.model != null) cfg.model) ++ cfg.extraModels;
        modelsAttrs = lib.listToAttrs (map (m: lib.nameValuePair m { name = m; }) allModels);
        providerConfig =
          providerConfigs.${cfg.provider}
          // lib.optionalAttrs (allModels != [ ]) {
            models = modelsAttrs;
          };
      in
      {
        force = true;
        text = builtins.toJSON (
          {
            "$schema" = "https://opencode.ai/config.json";
            provider.${cfg.provider} = providerConfig;
          }
          // lib.optionalAttrs (cfg.model != null) {
            model = "${cfg.provider}/${cfg.model}";
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
