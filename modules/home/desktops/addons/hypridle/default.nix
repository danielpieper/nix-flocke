{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.desktops.addons.hypridle;
in
{
  options.desktops.addons.hypridle = with types; {
    enable = mkBoolOpt false "Whether to enable the hypridle";
  };

  config = mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "noctalia-shell ipc call media pause";
          lock_cmd = "noctalia-shell ipc call lockScreen lock";
        };

        listener = [
          {
            timeout = 60;
            # jq -e, das mit Exit-Code 1 beendet wenn der Wert false ist, und Exit-Code 0 bei true.
            on-timeout = ''noctalia-shell ipc call state all | jq -e '.state.lockScreenActive' > /dev/null && systemctl suspend'';
          }
          {
            timeout = 5 * 60;
            on-timeout = "${pkgs.flocke.dim}/bin/dim --alpha 0.6 --duration 120 && loginctl lock-session";
          }
          {
            timeout = 8 * 60;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
