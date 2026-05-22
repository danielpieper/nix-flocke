{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.flocke.usbip-export;
  usbip = config.boot.kernelPackages.usbip;

  vidPidParts = splitString ":" cfg.deviceVidPid;
  vendorId = elemAt vidPidParts 0;
  productId = elemAt vidPidParts 1;

  # Shared sysfs walk to resolve VID:PID -> busid. Embedded into helpers so
  # the VID:PID is baked at build time and sudo doesn't need to allow args.
  findBusid = ''
    busid=""
    for dev in /sys/bus/usb/devices/[0-9]*-*; do
      [ -e "$dev/idVendor" ] || continue
      [ -e "$dev/idProduct" ] || continue
      if [ "$(cat "$dev/idVendor")" = "${vendorId}" ] \
         && [ "$(cat "$dev/idProduct")" = "${productId}" ]; then
        busid=$(basename "$dev")
        break
      fi
    done
  '';

  bindHelper = pkgs.writeShellApplication {
    name = "flocke-usbip-bind";
    runtimeInputs = [ usbip ];
    text = ''
      ${findBusid}
      if [ -z "$busid" ]; then
        echo "device ${vendorId}:${productId} not found" >&2
        exit 1
      fi
      driver=""
      if [ -L "/sys/bus/usb/devices/$busid/driver" ]; then
        driver=$(basename "$(readlink "/sys/bus/usb/devices/$busid/driver")")
      fi
      if [ "$driver" = "usbip-host" ]; then
        echo "already bound: $busid"
        exit 0
      fi
      usbip bind -b "$busid"
    '';
  };

  unbindHelper = pkgs.writeShellApplication {
    name = "flocke-usbip-unbind";
    runtimeInputs = [ usbip ];
    text = ''
      ${findBusid}
      if [ -z "$busid" ]; then
        exit 0
      fi
      usbip unbind -b "$busid" || true
    '';
  };

  moonlightStream = pkgs.writeShellApplication {
    name = "moonlight-stream";
    runtimeInputs = [ pkgs.moonlight-qt ];
    text = ''
      cleanup() {
        sudo -n flocke-usbip-unbind || true
      }
      trap cleanup EXIT INT TERM
      sudo -n flocke-usbip-bind
      moonlight "$@"
    '';
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "moonlight-stream";
    desktopName = "Moonlight (Streaming Pad)";
    comment = "Moonlight with USB controller forwarded to the stream host";
    exec = "${moonlightStream}/bin/moonlight-stream";
    icon = "qt-moonlight";
    categories = [ "Game" ];
    terminal = false;
    startupNotify = true;
  };
in
{
  options.services.flocke.usbip-export = {
    enable = mkBoolOpt false "Whether to export a USB device via usbip and wrap Moonlight to bind/unbind it around streaming";
    deviceVidPid =
      mkOpt types.str "28de:1304"
        "VID:PID of the USB device to export (default: Valve Steam Controller Puck)";
    user = mkOpt types.str "" "User allowed to invoke the bind/unbind helpers via sudo";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.user != "";
        message = "services.flocke.usbip-export.user must be set";
      }
    ];

    boot.kernelModules = [ "usbip_host" ];

    environment.systemPackages = [
      usbip
      bindHelper
      unbindHelper
      moonlightStream
      desktopItem
    ];

    systemd.services.usbipd = {
      description = "USB/IP daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${usbip}/bin/usbipd";
        Restart = "on-failure";
      };
    };

    # Listen only on the tailscale interface. Further restriction to a single
    # source IP belongs in Tailscale ACL, not the host firewall.
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 3240 ];

    security.sudo.extraRules = [
      {
        users = [ cfg.user ];
        commands = [
          {
            command = "/run/current-system/sw/bin/flocke-usbip-bind";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/flocke-usbip-unbind";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
