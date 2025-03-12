{
  inputs,
  ...
}:
{
  roles = {
    desktop.enable = true;
    social.enable = true;
  };
  desktops.hyprland.enable = true;

  cli = {
    programs = {
      git = {
        email = "daniel@ventx.de";
        signingKey = "/home/daniel/.ssh/id_ed25519_ventx.pub";
        allowedSigners = "/home/daniel/.ssh/id_ed25519_ventx.pub";
      };
      ssh.extraHosts = {
        "git.ventx.org" = {
          hostname = "git.ventx.org";
          identityFile = "/home/daniel/.ssh/id_ed25519_ventx.pub";
          identitiesOnly = true;
        };
      };
    };
    shells.fish.extraAbbrs = {
      wl = "nvim ~/Documents/worklog.txt";
    };
  };

  browsers.firefox.additionalProfiles = [
    {
      name = "ventx";
      id = 1;
    }
  ];

  flocke.user = {
    enable = true;
    name = "daniel";
  };

  home.packages = [
    inputs.ventx.packages.x86_64-linux.oidc2aws
  ];

  home.stateVersion = "23.11";
}
