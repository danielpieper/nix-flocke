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
    services.flatpak.enable = true; # geforce now
    programs = {
      gamescope.enable = true;
      gamemode.enable = true;
      steam = {
        enable = true;
        extest.enable = true; # XInput translation via uinput
        remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      };
    };
  };
}
