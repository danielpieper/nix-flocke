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
  # Wrap rather than exporting OPENROUTER_API_KEY from the shell profile, so the
  # key only ever lands in pi's own environment.
  pi-openrouter = pkgs.writeShellScriptBin "pi" ''
    if [ -z "''${OPENROUTER_API_KEY:-}" ] && [ -r "${keyPath}" ]; then
      OPENROUTER_API_KEY=$(cat "${keyPath}")
      export OPENROUTER_API_KEY
    fi
    exec ${getExe pkgs.llm-agents.pi} "$@"
  '';
in
{
  options.programs.flocke.pi = {
    enable = mkBoolOpt false "Enable the pi coding agent, backed by OpenRouter";
  };

  config = mkIf cfg.enable {
    sops.secrets.openrouter_api_key = { };

    home.packages = [ pi-openrouter ];
  };
}
