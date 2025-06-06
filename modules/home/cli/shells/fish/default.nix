{
  pkgs,
  lib,
  config,
  host,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  inherit (config.lib.stylix) colors;
  cfg = config.cli.shells.fish;
in
{
  options.cli.shells.fish = with types; {
    enable = mkBoolOpt false "enable fish shell";
    extraAbbrs = mkOption {
      type = attrsOf str;
      default = { };
      description = "Extra shell abbreviations to add to fish";
      example = literalExpression ''
        {
          gco = "git checkout";
          gp = "git push";
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    stylix.targets.fish.enable = false;
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        ${pkgs.nix-your-shell}/bin/nix-your-shell --nom fish | source
        set -x GOPATH $XDG_DATA_HOME/go
        # set -x GOPRIVATE "${inputs.nix-secrets.go.goprivate}"
        set -gx PATH /usr/local/bin /usr/bin ~/.local/bin $GOPATH/bin/ $PATH
        # fish_add_path --path --append $GOPATH/bin/
        # fish_add_path --path --append /usr/local/bin /usr/bin ~/.local/bin

        # fifc setup
        set -Ux fifc_editor nvim
        set -U fifc_keybinding \cx
        bind \cx _fifc
        bind -M insert \cx _fifc

        set -g fish_color_normal ${colors.base05}
        set -g fish_color_command ${colors.base0D}
        set -g fish_color_param ${colors.base0F}
        set -g fish_color_keyword ${colors.base08}
        set -g fish_color_quote ${colors.base0B}
        set -g fish_color_redirection f4b8e4
        set -g fish_color_end ${colors.base09}
        set -g fish_color_comment 838ba7
        set -g fish_color_error ${colors.base08}
        set -g fish_color_gray 737994
        set -g fish_color_selection --background=${colors.base02}
        set -g fish_color_search_match --background=${colors.base02}
        set -g fish_color_option ${colors.base0B}
        set -g fish_color_operator f4b8e4
        set -g fish_color_escape ea999c
        set -g fish_color_autosuggestion 737994
        set -g fish_color_cancel ${colors.base08}
        set -g fish_color_cwd ${colors.base0A}
        set -g fish_color_user ${colors.base0C}
        set -g fish_color_host ${colors.base0D}
        set -g fish_color_host_remote ${colors.base0B}
        set -g fish_color_status ${colors.base08}
        set -g fish_pager_color_progress 737994
        set -g fish_pager_color_prefix f4b8e4
        set -g fish_pager_color_completion ${colors.base05}
        set -g fish_pager_color_description 737994

        fish_vi_key_bindings
        set -g fish_vi_force_cursor 1
        set fish_cursor_default block blink
        set fish_cursor_insert line blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual block

        if status is-interactive
            if type -q zellij
                # Update the zellij tab name with the current process name or pwd.
                function zellij_tab_name_update_pre --on-event fish_preexec
                    if set -q ZELLIJ
                        set -l cmd_line (string split " " -- $argv)
                        set -l process_name $cmd_line[1]
                        if test -n "$process_name" -a "$process_name" != "z"
                            command nohup zellij action rename-tab $process_name >/dev/null 2>&1
                        end
                    end
                end

                function zellij_tab_name_update_post --on-event fish_postexec
                    if set -q ZELLIJ
                        set -l cmd_line (string split " " -- $argv)
                        set -l process_name $cmd_line[1]
                        if test "$process_name" = "z"
                            command nohup zellij action rename-tab (prompt_pwd) >/dev/null 2>&1
                        end
                    end
                end
            end
        end
      '';

      shellAliases = {
        wget = "wget --hsts-file=\"$XDG_DATA_HOME/wget-hsts\"";
      };
      shellAbbrs = {
        # abbr existing commands
        vim = "nvim";
        n = "nvim";
        ss = "zellij -l welcome";
        cd = "z";
        cdi = "zi";
        cp = "xcp";
        grep = "rg";
        dig = "dog";
        cat = "bat";
        curl = "curlie";
        rm = "gomi";
        ping = "gping";
        ls = "eza";
        sl = "eza";
        l = "eza --group --header --group-directories-first --long --git --all --binary --all --icons always";
        tree = "eza --tree";
        sudo = "sudo -E -s";
        k = "kubectl";
        kgp = "kubectl get pods";

        tsu = "tailscale up";
        tsd = "tailscale down";

        # nix
        nhh = "nh home switch";
        nho = "nh os switch";
        nhu = "nh os --update";

        nd = "nix develop";
        nfu = "nix flake update";
        hms = "home-manager switch --flake ~/Projects/nix-flocke#${config.flocke.user.name}@${host}";
        nrs = "sudo nixos-rebuild switch --flake ~/Projects/nix-flocke#${host}";

        pfile = "fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'";
        gdub = "git fetch -p && git branch -vv | grep ': gone]' | awk '{print }' | xargs git branch -D $argv;";
        tldrf = "${pkgs.tldr}/bin/tldr --list | fzf --preview \"${pkgs.tldr}/bin/tldr {1} --color\" --preview-window=right,70% | xargs tldr";
        dk = "docker kill (docker ps -q)";
        ds = "docker stop (docker ps -a -q)";
        drm = "docker rm (docker ps -a -q)";
        docker-compose = "podman-compose";
        dc = "podman-compose";

        # Git
        g = "git";
        ga = "git add";
        gaa = "git add --all";

        gb = "git branch";
        gba = "git branch --all";
        gbd = "git branch --delete";
        gbD = "git branch --delete --force";
        gbl = "git blame -b -w";
        gbr = "git branch --remote";

        gc = "git commit --verbose";
        gca = "git commit --verbose --all";
        gcam = "git commit --all --message";
        gcb = "git checkout -b";

        gcmsg = "git commit --message";
        gco = "git checkout";
        gcp = "git cherry-pick";

        gd = "git diff";
        gds = "git diff --staged";
        gdt = "git diff-tree --no-commit-id --name-only -r";
        gdw = "git diff --word-diff";

        gl = "git pull";
        glog = "git log --oneline --decorate --graph";

        gm = "git merge";
        gmtl = "git mergetool --no-prompt";

        gp = "git push";
        gpd = "git push --dry-run";
        gpf = "git push --force-with-lease --force-if-includes";
        gpr = "git pull --rebase";

        grbi = "git rebase --interactive";
        grba = "git rebase --abort";
        grbc = "git rebase --continue";

        gst = "git status";
      } // cfg.extraAbbrs;

      functions = {
        fish_greeting = '''';

        envsource = ''
          for line in (cat $argv | grep -v '^#')
            set item (string split -m 1 '=' $line)
            set -gx $item[1] $item[2]
            echo "Exported key $item[1]"
          end
        '';

        gcrb = ''
            set result (git branch -a --color=always | grep -v '/HEAD\s' | sort |
              fzf --height 50% --border --ansi --tac --preview-window right:70% \
                --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" (string sub -s 3 (string split ' ' {})[1]) | head -'$LINES |
              string sub -s 3 | string split ' ' -m 1)[1]

            if test -n "$result"
              if string match -r "^remotes/.*" $result > /dev/null
                git checkout --track (string replace -r "^remotes/" "" $result)
              else
                git checkout $result
              end
            end
          end
        '';

        hmg = ''
          set current_gen (home-manager generations | head -n 1 | awk '{print $7}')
          home-manager generations | awk '{print $7}' | tac | fzf --preview "echo {} | xargs -I % sh -c 'nvd --color=always diff $current_gen %' | xargs -I{} bash {}/activate"
        '';

        rgvim = ''
          rg --color=always --line-number --no-heading --smart-case "$argv" |
            fzf --ansi \
                --color "hl:-1:underline,hl+:-1:underline:reverse" \
                --delimiter : \
                --preview 'bat --color=always {1} --highlight-line {2}' \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
                --bind 'enter:become(nvim {1} +{2})'
        '';

        fish_command_not_found = ''
          # If you run the command with comma, running the same command
          # will not prompt for confirmation for the rest of the session
          if contains $argv[1] $__command_not_found_confirmed_commands
            or ${pkgs.gum}/bin/gum confirm --selected.background=2 "Run using comma?"

            # Not bothering with capturing the status of the command, just run it again
            if not contains $argv[1] $__command_not_found_confirmed_commands
              set -ga __fish_run_with_comma_commands $argv[1]
            end

            comma -- $argv
            return 0
          else
            __fish_default_command_not_found_handler $argv
          end
        '';
      };
      plugins = [
        {
          name = "bass";
          inherit (pkgs.fishPlugins.bass) src;
        }
        {
          name = "fzf-fish";
          inherit (pkgs.fishPlugins.fzf-fish) src;
        }
        {
          name = "fifc";
          inherit (pkgs.fishPlugins.fifc) src;
        }
        # {
        #   name = "kubectl-abbr";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "lewisacidic";
        #     repo = "fish-kubectl-abbr";
        #     rev = "161450ab83da756c400459f4ba8e8861770d930c";
        #     sha256 = "sha256-iKNaD0E7IwiQZ+7pTrbPtrUcCJiTcVpb9ksVid1J6A0=";
        #   };
        # }
        # {
        #   name = "git-abbr";
        #   inherit (pkgs.fishPlugins.git-abbr) src;
        # }
      ];
    };
  };
}
