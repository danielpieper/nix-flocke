{ pkgs, ... }:
{
  desktops = {
    hyprland = {
      enable = true;
      execOnceExtras = [
        "${pkgs.trayscale}/bin/trayscale"
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
    video.enable = true;
  };

  flocke.user = {
    enable = true;
    name = "daniel";
  };

  home.stateVersion = "23.11";
}