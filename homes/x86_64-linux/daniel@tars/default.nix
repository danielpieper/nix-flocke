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
  ];

  roles = {
    desktop.enable = true;
    social.enable = true;
    video.enable = false;
  };

  flocke.user = {
    enable = true;
    name = "daniel";
  };

  home.stateVersion = "23.11";
}
