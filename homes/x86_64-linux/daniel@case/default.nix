{ pkgs, ... }:
{
  desktops = {
    hyprland = {
      enable = true;
      execOnceExtras = [
        "${pkgs.networkmanagerapplet}/bin/nm-applet"
        "${pkgs.blueman}/bin/blueman-applet"
      ];
    };
  };

  home.packages = with pkgs; [
    nwg-displays
    blueman
    networkmanagerapplet
  ];

  roles = {
    desktop.enable = true;
    social.enable = false;
    video.enable = false;
  };

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

  home.stateVersion = "23.11";
}
