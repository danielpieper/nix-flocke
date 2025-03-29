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
        extraConfig.pipewire = {
          "10-sbc-xq" = {
            "bluez5.enable-sbc-xq" = true;
          };
        };
      };
    };

    security.rtkit.enable = true;
    programs.noisetorch.enable = true;

    environment.systemPackages = with pkgs; [
      pulsemixer
    ];
  };
}
