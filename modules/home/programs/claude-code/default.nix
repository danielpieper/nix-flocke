{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.programs.flocke.claude-code;
  gitCfg = config.programs.git;
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (inputs.agent-sandbox.lib.${system}) mkSandbox;
in
{
  options.programs.flocke.claude-code = with types; {
    enable = mkBoolOpt false "Enable sandboxed claude-code CLI agent";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (mkSandbox {
        pkg = pkgs.llm-agents.claude-code;
        binName = "claude";
        outName = "claude";
        allowedPackages = with pkgs; [
          coreutils
          bash
          git
          ripgrep
          fd
          gnused
          gnugrep
          findutils
          jq
          which
          python3
          yq
          openssh # only to deploy to rpi4
          go_1_26
          golangci-lint
          just
          tailwindcss_4
          postgresql_18
          ungoogled-chromium
          podman
        ];
        stateDirs = [ "$HOME/.claude" ];
        stateFiles = [
          "$HOME/.claude.json"
          "$HOME/.claude.json.lock"
        ];
        # restrictNetwork = true;
        # allowedDomains = [
        #   "httpbin.org"
        #   "github.com"
        # ];
        extraEnv = {
          ANTHROPIC_API_KEY = "$ANTHROPIC_API_KEY";
          GIT_AUTHOR_NAME = gitCfg.settings.user.name;
          GIT_AUTHOR_EMAIL = gitCfg.settings.user.email;
          GIT_COMMITTER_NAME = gitCfg.settings.user.name;
          GIT_COMMITTER_EMAIL = gitCfg.settings.user.email;
        };
      })
    ];
  };
}
