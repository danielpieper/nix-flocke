{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.llama-cpp;
  modelName = "TheBloke_CodeLlama-70B-hf-GGUF_codellama-70b-hf.Q2_K.gguf";
  # modelName = "rodrigomt_Qwen3-30B-A3B-Thinking-Deepseek-Distill-2507-v3.1-V2-GGUF_Qwen3-30B-A3B-Thinking-Deepseek-Distill-2507-v3.1-V2-UD-Q3_K_XL.gguf";
in
{
  options.services.flocke.llama-cpp = {
    enable = mkEnableOption "Enable llama.cpp - Local LLMs";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.llama-cpp-vulkan ];
    services.llama-cpp = {
      enable = true;
      model = "/var/lib/llama-cpp/models/${modelName}";
      package = pkgs.llama-cpp-vulkan;
      port = 3000;
      extraFlags = [
        "-v"
        "--jinja"
        "--ctx-size 16384"
      ];
    };
    systemd.services.llama-cpp.serviceConfig.ExecStart =
      lib.mkForce "${pkgs.llama-cpp-vulkan}/bin/llama-server -v --jinja --ctx-size 74000 --host localhost --port 3000 -m /var/lib/llama-cpp/models/${modelName}";
  };
}
