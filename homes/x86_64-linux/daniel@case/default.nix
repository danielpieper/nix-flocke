{
  inputs,
  pkgs,
  ...
}:
let
  publicKey = "/home/${inputs.nix-secrets.user.name}/.ssh/${inputs.nix-secrets.work.publicKeyFilename}";
in
{
  roles = {
    desktop.enable = true;
    social.enable = true;
  };
  desktops.hyprland.enable = true;

  cli = {
    programs = {
      git = {
        email = inputs.nix-secrets.work.email;
        signingKey = publicKey;
        allowedSigners = publicKey;
      };
      ssh.extraHosts = {
        "${inputs.nix-secrets.work.sshExtraHost}" = {
          hostname = inputs.nix-secrets.work.sshExtraHost;
          identityFile = publicKey;
          identitiesOnly = true;
        };
      };
    };
    shells.fish.extraAbbrs = {
      wl = "nvim ~/Documents/worklog.txt";
    };
  };

  browsers.firefox = {
    additionalProfiles = [
      {
        name = inputs.nix-secrets.work.company;
        id = 1;
      }
    ];
    defaultLinkProfile = inputs.nix-secrets.work.company;
  };

  flocke.user = {
    enable = true;
    name = inputs.nix-secrets.user.name;
  };

  home.packages = [
    inputs.ventx.packages.x86_64-linux.oidc2aws
    pkgs.slack
  ];

  home.stateVersion = "23.11";
}
