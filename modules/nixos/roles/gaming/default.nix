{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.roles.gaming;
in
{
  options.roles.gaming = {
    enable = mkEnableOption "Enable gaming configuration";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
  };
}
