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
        model = "qwen3.6:35b-a3b-q8-coding";
        extraModels = [
          "qwen3.6:27b-q8-coding"
        ];
      };
      claude-code.enable = true;
      lm-studio.enable = false;
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
          hostname = inputs.nix-secrets.work.sshExtraHost;
          identityFile = publicKeyWork;
          identitiesOnly = true;
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
