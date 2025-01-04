{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.hardware.audio;
in
{
  options.hardware.audio = with types; {
    enable = mkBoolOpt false "Enable or disable hardware audio support";
  };

  config = mkIf cfg.enable {
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        wireplumber.enable = true;
      };
      udev.packages = with pkgs; [
        headsetcontrol
      ];
    };

    security.rtkit.enable = true;
    programs.noisetorch.enable = true;

    environment.systemPackages = with pkgs; [
      headsetcontrol
      headset-charge-indicator
      pulsemixer
    ];
  };
}
