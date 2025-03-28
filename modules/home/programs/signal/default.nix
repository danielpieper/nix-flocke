{ config
, lib
, pkgs
, ...
}:
with lib;
with lib.flocke;
let
  cfg = config.programs.signal;
in
{
  options.programs.signal = with types; {
    enable = mkBoolOpt false "Enable Signal - Private, simple, and secure messenger";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ signal-desktop ];
  };
}
