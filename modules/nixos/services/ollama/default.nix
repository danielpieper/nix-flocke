{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.flocke.ollama;
in
{
  options.services.flocke.ollama = {
    enable = mkEnableOption "Enable Ollama - Local LLMs";
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      acceleration = "rocm";
      loadModels = [
        "qwen3-coder:30b"
        "deepseek-r1:70b"
      ];
      # environmentVariables = {
      #   HCC_AMDGPU_TARGET = "gfx1150";
      #   HSA_OVERRIDE_GFX_VERSION = "11.5.1";
      #   OLLAMA_DEBUG = "1";
      #   AMD_LOG_LEVEL = "3";
      # };
      # results in environment variable "HSA_OVERRIDE_GFX_VERSION=11.5.1"
      rocmOverrideGfx = "11.5.0";
    };
    # http://localhost:3000
    services.nextjs-ollama-llm-ui.enable = true;
  };
}
