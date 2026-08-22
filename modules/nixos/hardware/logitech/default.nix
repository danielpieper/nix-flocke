{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.hardware.logitechMouse;
in
{
  options.hardware.logitechMouse = with types; {
    enable = mkBoolOpt false "Enable logitech mouse hardware for their mice";
  };

  config = mkIf cfg.enable {
    hardware.logitech.wireless.enable = true;

    # Solaar. Also pulls pkgs.solaar into environment.systemPackages.
    programs.solaar.enable = true;

    services.udev.packages = with pkgs; [
      logitech-udev-rules
      solaar
    ];
  };
}
