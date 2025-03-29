{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.browsers.tor;
in
{
  options.browsers.tor = {
    enable = mkEnableOption "enable tor browser";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      tor-browser-bundle-bin
    ];
  };
}
