{
  config,
  inputs,
  pkgs,
  ...
}:
let
  publicKeyWork = "/home/${inputs.nix-secrets.user.name}/.ssh/${inputs.nix-secrets.work.publicKeyFilename}";
  vlcSchweinerei = pkgs.writeShellScriptBin "vlc-schweinerei" ''
    exec ${pkgs.vlc}/bin/vlc --fullscreen "$(cat ${config.sops.secrets.schweinerei_rtsp_url.path})"
  '';
in
{
  roles = {
    desktop.enable = true;
    social.enable = true;
    gaming.enable = true;
  };

  programs = {
    neovim = {
      withRuby = false;
      withPython3 = false;
    };
    firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
    flocke = {
      opencode = {
        enable = false;
        provider = "ollama";
        baseUrl = "http://localhost:11434/v1";
        model = "hf.co/unsloth/Qwen3.8-27B-GGUF:UD-Q8_K_XL";
        extraModels = [
          "qwen3.8:27b"
        ];
      };
      claude-code.enable = true;
      pi = {
        enable = true;
        # Ollama speaks the OpenAI API but pi has no built-in local backend, so
        # it is registered as a custom provider. The key is a placeholder that
        # Ollama ignores; pi hides models with no auth configured, so dropping
        # it would make qwen3.8 invisible in /model. Both compat flags follow
        # pi's own Ollama guidance: Ollama rejects the `developer` role, and
        # reasoning_effort is left unsent (the model still thinks server-side).
        defaultProvider = "ollama";
        defaultModel = "hf.co/unsloth/Qwen3.8-27B-GGUF:UD-Q8_K_XL";
        providers.ollama = {
          baseUrl = "http://localhost:11434/v1";
          api = "openai-completions";
          apiKey = "ollama";
          compat = {
            supportsDeveloperRole = false;
            supportsReasoningEffort = false;
          };
          models = [
            {
              id = "hf.co/unsloth/Qwen3.8-27B-GGUF:UD-Q8_K_XL";
              reasoning = true;
            }
            {
              id = "qwen3.8:27b";
              reasoning = true;
            }
          ];
        };
      };
      lm-studio.enable = false;
      futo-notes.enable = true;
    };
    git.includes = [
      {
        condition = "gitdir:~/Projects/${inputs.nix-secrets.work.company}/**";
        contents.user = {
          inherit (inputs.nix-secrets.work) email;
          signingKey = publicKeyWork;
        };
      }
    ];
  };
  desktops = {
    niri.enable = true;
  };

  # Noctalia fires this hook when its theme mode changes, exporting
  # $NOCTALIA_THEME_MODE = "dark" | "light" | "auto". flocke-theme-switch flips
  # between the base (dark) system and the `light` specialisation via
  # switch-to-configuration.
  programs.noctalia.settings.hooks = {
    theme_mode_changed = "sudo -n flocke-theme-switch \"$NOCTALIA_THEME_MODE\"";
  };

  cli = {
    programs = {
      git = {
        allowedSigners = [
          {
            inherit (inputs.nix-secrets.user) email;
            key = inputs.nix-secrets.user.pubKey;
          }
          {
            inherit (inputs.nix-secrets.work) email;
            key = inputs.nix-secrets.work.pubKey;
          }
        ];
        urlRewrites = {
          "ssh://forgejo@forgejo.${inputs.nix-secrets.homelabDomain}" =
            "https://forgejo.${inputs.nix-secrets.homelabDomain}";
        };
      };
      ssh.extraHosts = {
        "${inputs.nix-secrets.work.sshExtraHost}" = {
          HostName = inputs.nix-secrets.work.sshExtraHost;
          IdentityFile = publicKeyWork;
          IdentitiesOnly = true;
        };
      };
    };
    shells.fish.extraAbbrs = {
      wl = "nvim ~/Documents/${inputs.nix-secrets.work.company}/worklog.txt";
    };
  };

  browsers.firefox = {
    additionalProfiles = [
      {
        name = inputs.nix-secrets.work.company;
        id = 1;
      }
    ];
    # defaultLinkProfile = inputs.nix-secrets.work.company;
  };

  flocke.user = {
    enable = true;
    inherit (inputs.nix-secrets.user) name;
  };

  sops.secrets.schweinerei_rtsp_url = { };

  xdg.desktopEntries = {
    "vlc-schweinerei" = {
      type = "Application";
      name = "Schweinerei";
      exec = "${vlcSchweinerei}/bin/vlc-schweinerei";
      comment = "Guinea pig camera stream";
      icon = "vlc";
      categories = [
        "AudioVideo"
        "Video"
        "Player"
      ];
      terminal = false;
    };
  };

  home = {
    sessionVariables = {
      GOPRIVATE = inputs.nix-secrets.go.goprivate;
      # OP_SERVICE_ACCOUNT_TOKEN = "$(cat ${config.sops.secrets.opServiceAccountToken.path})";
    };
    # packages = [
    #   inputs.ventx.packages.x86_64-linux.oidc2aws
    # ];
    stateVersion = "23.11";
  };
}
