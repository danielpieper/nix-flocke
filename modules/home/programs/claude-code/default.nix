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
    home.file.".claude/statusline-command.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Claude Code status line: dir | model | git branch | ctx bar | rate bar

        input=$(cat)

        # Current working directory (abbreviated with ~)
        raw_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
        dir="''${raw_dir/#$HOME/\~}"

        # Model display name
        model=$(echo "$input" | jq -r '.model.display_name // empty')

        # Git branch (skip optional locks to avoid blocking)
        branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$(echo "$input" | jq -r '.workspace.current_dir // empty')" symbolic-ref --short HEAD 2>/dev/null)

        # Context usage (pre-calculated percentage)
        used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

        # Token counts from last API call
        input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
        output_tokens=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // empty')

        # Rate limit (5-hour window)
        rate_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

        # Progress bar helper: make_bar <percentage> [width=10]
        make_bar() {
            local pct=$1 width=''${2:-10}
            local filled=$(printf "%.0f" "$(echo "$pct * $width / 100" | bc -l)")
            local empty=$((width - filled))
            [ "$filled" -gt 0 ] && printf '%0.s█' $(seq 1 "$filled")
            [ "$empty"  -gt 0 ] && printf '%0.s░' $(seq 1 "$empty")
        }

        # Build status parts
        parts=()

        [ -n "$dir" ]    && parts+=("$dir")
        [ -n "$model" ]  && parts+=("$model")
        [ -n "$branch" ] && parts+=("$branch")

        # Context window bar
        if [ -n "$used_pct" ]; then
            bar=$(make_bar "$used_pct")
            entry="ctx $bar $(printf '%.0f' "$used_pct")%"
            if [ -n "$input_tokens" ] && [ -n "$output_tokens" ]; then
                total=$((input_tokens + output_tokens))
                if [ "$total" -ge 1000 ]; then
                    tok=$(printf '%dk' "$((total / 1000))")
                else
                    tok=$(printf '%d' "$total")
                fi
                entry="$entry · ''${tok}"
            fi
            parts+=("$entry")
        fi

        # Rate limit bar (5-hour window)
        if [ -n "$rate_pct" ]; then
            bar=$(make_bar "$rate_pct")
            parts+=("rate $bar $(printf '%.0f' "$rate_pct")%")
        fi

        # Join with separator and print
        printf '%s' "$(IFS=' | '; echo "''${parts[*]}")"
      '';
    };

    home.packages =
      let
        claude-sandboxed = mkSandbox {
          pkg = pkgs.llm-agents.claude-code;
          binName = "claude";
          outName = "claude-sandboxed";
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
            curl
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
            nixos-rebuild
            gcc
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
            # ANTHROPIC_API_KEY = "$ANTHROPIC_API_KEY";
            GIT_AUTHOR_NAME = gitCfg.settings.user.name;
            GIT_AUTHOR_EMAIL = gitCfg.settings.user.email;
            GIT_COMMITTER_NAME = gitCfg.settings.user.name;
            GIT_COMMITTER_EMAIL = gitCfg.settings.user.email;
          };
        };
        claude-yolo = pkgs.writeShellScriptBin "claude-yolo" ''
          exec ${claude-sandboxed}/bin/claude-sandboxed --continue --dangerously-skip-permissions "$@"
        '';
      in
      [
        pkgs.llm-agents.claude-code
        claude-sandboxed
        claude-yolo
      ];
  };
}
