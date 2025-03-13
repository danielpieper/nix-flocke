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
    signingKey = mkOpt str "/home/daniel/.ssh/id_ed25519.pub" "The public key used for signing commits";
    allowedSigners = mkOpt str "" "List of public keys to verify commit signatures locally";
  };

  config = mkIf cfg.enable {
    home = {
      file.".ssh/allowed_signers".text = ''
        * /home/daniel/.ssh/id_ed25519.pub
        * ${cfg.allowedSigners}
      '';
      packages = with pkgs; [
        git-extras
        git-absorb
      ];
    };

    programs.git = {
      enable = true;
      userName = "Daniel Pieper";
      userEmail = cfg.email;
      signing = {
        signByDefault = true;
        format = "ssh";
        key = cfg.signingKey;
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
          fixup = "!echo \"Use git absorb\"";
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
