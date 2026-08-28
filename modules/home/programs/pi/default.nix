{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.programs.flocke.pi;
  keyPath = config.sops.secrets.openrouter_api_key.path;
  hasDefault = cfg.defaultProvider != null && cfg.defaultModel != null;
  # Wrap rather than exporting OPENROUTER_API_KEY from the shell profile, so the
  # key only ever lands in pi's own environment.
  #
  # The default model has to be injected as flags: PI_PROVIDER/PI_MODEL are
  # values pi exports *into* its bash tool rather than inputs it reads, and
  # settings.json is pi's own file to rewrite whenever the model is switched in
  # the TUI. Flags are added only when the caller picked neither a provider nor
  # a model, and never in front of a subcommand, which parses its own options.
  pi-openrouter = pkgs.writeShellScriptBin "pi" ''
    if [ -z "''${OPENROUTER_API_KEY:-}" ] && [ -r "${keyPath}" ]; then
      OPENROUTER_API_KEY=$(cat "${keyPath}")
      export OPENROUTER_API_KEY
    fi
    ${optionalString hasDefault ''
      case "''${1:-}" in
        install | remove | uninstall | update | list | config | auth) ;;
        *)
          case " $* " in
            *" --provider "* | *" --provider="* | *" --model "* | *" --model="*) ;;
            *) set -- --provider ${escapeShellArg cfg.defaultProvider} --model ${escapeShellArg cfg.defaultModel} "$@" ;;
          esac
          ;;
      esac
    ''}
    exec ${getExe pkgs.llm-agents.pi} "$@"
  '';
in
{
  options.programs.flocke.pi = {
    enable = mkBoolOpt false "Enable the pi coding agent, backed by OpenRouter";

    defaultProvider = mkOpt (types.nullOr types.str) null ''
      Provider pi selects when the caller passes neither --provider nor --model.
      Must be set together with defaultModel.
    '';

    defaultModel = mkOpt (types.nullOr types.str) null ''
      Model pi selects when the caller passes neither --provider nor --model.
      Must be set together with defaultProvider.
    '';

    providers = mkOpt (types.attrsOf types.anything) { } ''
      Custom providers rendered to ~/.pi/agent/models.json. Anything speaking
      the OpenAI, Anthropic or Google API can be added here, which is how local
      servers such as Ollama are reached.
    '';
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.defaultProvider == null) == (cfg.defaultModel == null);
        message = "programs.flocke.pi: defaultProvider and defaultModel must be set together.";
      }
    ];

    sops.secrets.openrouter_api_key = { };

    home.packages = [ pi-openrouter ];

    home.file = mkIf (cfg.providers != { }) {
      ".pi/agent/models.json".text = builtins.toJSON { inherit (cfg) providers; };
    };
  };
}
