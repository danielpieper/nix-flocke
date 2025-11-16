{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.virtualisation.podman;
in
{
  options.services.flocke.virtualisation.podman = {
    enable = mkEnableOption "Enable podman";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ podman-tui ];
    virtualisation = {
      podman = {
        enable = true;
        dockerSocket.enable = true;
        dockerCompat = true;
        defaultNetwork.settings = {
          dns_enabled = true;
        };
      };
    };
  };
}
