{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.kdeconnect;
in
{
  options.services.flocke.kdeconnect = with types; {
    enable = mkBoolOpt false "Whether or not to enable kdeconnect";
  };

  config = mkIf cfg.enable {
    # programs.kdeconnect automatically opens firewall ports 1714-1764
    programs.kdeconnect.enable = true;
  };
}
