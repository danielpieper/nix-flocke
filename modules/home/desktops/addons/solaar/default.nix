{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.desktops.addons.solaar;
in
{
  options.desktops.addons.solaar = {
    enable = mkEnableOption "Enable Solaar rules for Logitech mice";
  };

  config = mkIf cfg.enable {
    # Rules are evaluated by the Solaar daemon, which niri autostarts as
    # `solaar -w hide`. They only fire for buttons that are diverted, i.e. that
    # send a HID++ notification instead of their normal event. Diversion is
    # device state kept in ~/.config/solaar/config.yaml, next to DPI and smart
    # shift; set it once per mouse with:
    #
    #   solaar config "MX Master 3S" divert-keys "Mouse Gesture Button" Diverted
    #
    # KeyPress is simulated through /dev/uinput, since XTEST does not exist on
    # Wayland. The udev rules shipped with Solaar (pulled in by
    # hardware.logitechMouse) tag that node with uaccess, so the session user
    # may write to it.
    #
    # MX Master 3S gesture button (under the thumb rest) -> niri overview,
    # by way of the Mod+Up bind in the niri keybindings.
    xdg.configFile."solaar/rules.yaml".text = ''
      %YAML 1.3
      ---
      - Key: [Mouse Gesture Button, pressed]
      - KeyPress:
        - [Super_L, Up]
        - click
      ...
    '';
  };
}
