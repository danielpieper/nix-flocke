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
      vulkan = pkgs.ollama-vulkan;
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
        "vulkan"
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
        # Ollama discards integrated GPUs unless this is set, falling back to
        # CPU. On an APU the iGPU is the only accelerator there is, and with no
        # GPU claimed Ollama also reports total_vram=0 and drops its
        # VRAM-scaled context window to the 4096 floor.
        OLLAMA_IGPU_ENABLE = "1";
      };
    };

    environment.systemPackages = [ ollamaPackage ];
  };
}
