{
  inputs,
  pkgs,
  ...
}:
let
  publicKeyWork = "/home/${inputs.nix-secrets.user.name}/.ssh/${inputs.nix-secrets.work.publicKeyFilename}";
in
{
  roles = {
    desktop.enable = true;
    social.enable = true;
    gaming.enable = true;
  };

  programs = {
    flocke = {
      opencode = {
        enable = true;
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

  cli = {
    programs = {
      git = {
        allowedSigners = publicKeyWork;
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

  xdg.desktopEntries = {
    "vlc-schweinerei" = {
      type = "Application";
      name = "Schweinerei";
      exec = "vlc --fullscreen rtsp://cam.${inputs.nix-secrets.tailscaleDomain}:8080/h264.sdp";
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
    packages = [
      inputs.ventx.packages.x86_64-linux.oidc2aws
      pkgs.pi-coding-agent
    ];
    stateVersion = "23.11";
  };
}
