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
  # noctalia v5's `status` IPC no longer exposes lockScreenActive, so gate the
  # 60s suspend on logind's LockedHint (set by `loginctl lock-session`) instead.
  suspendIfLocked = pkgs.writeShellScript "suspend-if-locked" ''
    sid="''${XDG_SESSION_ID:-}"
    if [ -z "$sid" ]; then
      sid=$(${pkgs.systemd}/bin/loginctl list-sessions --no-legend \
        | ${pkgs.gawk}/bin/awk -v u="$USER" '$3 == u { print $1; exit }')
    fi
    locked=$(${pkgs.systemd}/bin/loginctl show-session "$sid" -p LockedHint --value 2>/dev/null)
    [ "$locked" = "yes" ] && exec ${pkgs.systemd}/bin/systemctl suspend
  '';
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
          before_sleep_cmd = "loginctl lock-session; noctalia msg media stop";
          lock_cmd = "noctalia msg session lock";
        };

        listener = [
          {
            timeout = 60;
            # Suspend only if the session is already locked (LockedHint=yes).
            on-timeout = "${suspendIfLocked}";
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
