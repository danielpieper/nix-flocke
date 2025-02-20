{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.programs.git;

  rewriteURL = lib.mapAttrs' (key: value: {
    name = "url.${key}";
    value = {
      insteadOf = value;
    };
  }) cfg.urlRewrites;
in
{
  options.cli.programs.git = with types; {
    enable = mkBoolOpt false "Whether or not to enable git.";
    email = mkOpt (nullOr str) "daniel@daniel-pieper.com" "The email to use with git.";
    urlRewrites = mkOpt (attrsOf str) { } "url we need to rewrite i.e. ssh to http";
    allowedSigners = mkOpt str "" "The public key used for signing commits";
  };

  config = mkIf cfg.enable {
    home.file.".ssh/allowed_signers".text = ''
      * /home/daniel/.ssh/id_ed25519.pub
      * ${cfg.allowedSigners}
    '';

    programs.git = {
      enable = true;
      userName = "Daniel Pieper";
      userEmail = cfg.email;
      signing = {
        signByDefault = true;
        format = "ssh";
        key = "~/.ssh/id_ed25519.pub";
        signer = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };

      ignores = [
        "tags"
        ".idea"
        "*.sublime-project"
        "*.sublime-workspace"
        "_ide_helper.php"
        "_ide_helper_models.php"
        ".phpstorm.meta.php"
        ".vscode"
        ".projections.json"
        ".php_cs.cache"
        ".jira.d"
        ".DS_Store"
        ".vim"
        "phpstan.neon"
        ".direnv"
      ];

      extraConfig = {
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        commit.gpgsign = true;

        core = {
          editor = lib.getExe pkgs.neovim;
          pager = lib.getExe pkgs.delta;
        };

        color = {
          ui = true;
        };

        interactive = {
          diffFilter = "delta --color-only";
        };

        delta = {
          enable = true;
          options = {
            dark = "true";
            side-by-side = "false";
            line-numbers = "true";
            navigate = "true";
            syntax-theme = "catppuccin";
            # syntax-theme = "Monokai Extended";
          };
        };

        pull = {
          ff = "only";
        };

        push = {
          default = "current";
          autoSetupRemote = true;
        };

        init = {
          defaultBranch = "main";
        };

        alias = {
          fixup = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf --bind 'j:down,k:up' | cut -c -7 | xargs -o git commit --fixup";
        };

        merge = {
          tool = lib.getExe pkgs.neovim;
        };
        mergetool = {
          prompt = false;
          keepBackup = false;
        };
        "mergetool \"nvim\"" = {
          cmd = "nvim -f -c \"Gdiffsplit!\" \"$MERGED\" ";
        };
        rebase = {
          autoStash = true;
          autoSquash = true;
        };
      } // rewriteURL;
    };
  };
}
