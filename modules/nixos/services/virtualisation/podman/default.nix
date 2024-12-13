{
  config,
  lib,
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
