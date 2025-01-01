{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.browsers.google-chrome;
in
{
  options.browsers.google-chrome = {
    enable = mkEnableOption "enable google-chrome browser";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      google-chrome
    ];
  };
}
