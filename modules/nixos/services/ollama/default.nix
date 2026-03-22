{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.ollama;
  ollamaPackage =
    {
      cpu = pkgs.ollama-cpu;
      rocm = pkgs.ollama-rocm;
      cuda = pkgs.ollama-cuda;
    }
    .${cfg.acceleration};
in
{
  options.services.flocke.ollama = {
    enable = mkEnableOption "Enable Ollama LLM server";

    acceleration = mkOption {
      type = types.enum [
        "cpu"
        "rocm"
        "cuda"
      ];
      default = "cpu";
      description = "Hardware acceleration backend to use";
    };

    loadModels = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Models to pull on activation";
    };
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = ollamaPackage;
      inherit (cfg) loadModels;
      environmentVariables = {
        OLLAMA_KV_CACHE_TYPE = "q8_0";
        HSA_ENABLE_SDMA = "0";
      };
    };

    environment.systemPackages = [ ollamaPackage ];
  };
}
