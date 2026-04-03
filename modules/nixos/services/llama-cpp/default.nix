{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.llama-cpp;
in
{
  options.services.flocke.llama-cpp = {
    enable = mkEnableOption "Enable llama.cpp inference server";

    acceleration = mkOption {
      type = types.enum [
        "cpu"
        "rocm"
        "vulkan"
      ];
      default = "cpu";
      description = "Hardware acceleration backend to use";
    };

    port = mkOption {
      type = types.port;
      default = 11434;
      description = "Port for the llama-server API";
    };

    modelsPreset = mkOption {
      type = types.nullOr (types.attrsOf types.attrs);
      default = null;
      description = "Models preset configuration (INI format, auto-downloads from HuggingFace)";
    };

    model = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to a local GGUF model file";
    };

    contextSize = mkOption {
      type = types.int;
      default = 32768;
      description = "Context window size";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra flags passed to llama-server";
    };
  };

  config = mkIf cfg.enable {
    services.llama-cpp = {
      enable = true;
      package = pkgs.llama-cpp.override {
        vulkanSupport = cfg.acceleration == "vulkan";
        rocmSupport = cfg.acceleration == "rocm";
      };
      inherit (cfg) port model modelsPreset;
      extraFlags = [
        "--jinja"
        "-ngl"
        "99"
        "--ctx-size"
        (toString cfg.contextSize)
      ]
      ++ cfg.extraFlags;
    };

    environment.systemPackages = [ config.services.llama-cpp.package ];
  };
}
