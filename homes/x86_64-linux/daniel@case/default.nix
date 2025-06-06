{
  inputs,
  ...
}:
let
  publicKeyWork = "/home/${inputs.nix-secrets.user.name}/.ssh/${inputs.nix-secrets.work.publicKeyFilename}";
in
{
  roles = {
    desktop.enable = true;
    social.enable = true;
  };
  desktops.hyprland.enable = true;

  programs.git.includes = [
    {
      condition = "gitdir:~/Projects/${inputs.nix-secrets.work.company}/**";
      contents.user = {
        inherit (inputs.nix-secrets.work) email;
        signingKey = publicKeyWork;
      };
    }
  ];

  cli = {
    programs = {
      git.allowedSigners = publicKeyWork;
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

  home.packages = [
    inputs.ventx.packages.x86_64-linux.oidc2aws
  ];

  home.stateVersion = "23.11";
}
