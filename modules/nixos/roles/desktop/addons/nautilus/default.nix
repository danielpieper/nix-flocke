{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.roles.desktop.addons.nautilus;
in
{
  options.roles.desktop.addons.nautilus = with types; {
    enable = mkBoolOpt false "Whether to enable the gnome file manager.";
  };

  config = mkIf cfg.enable {
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    environment = {
      sessionVariables = {
        NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
        NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";
      };

      pathsToLink = [
        "/share/nautilus-python/extensions"
      ];

      systemPackages = with pkgs; [
        ffmpegthumbnailer # thumbnails
        nautilus-open-any-terminal
        nautilus-python
      ];
    };

    snowfallorg.users.${config.user.name}.home.config = {
      dconf.settings = {
        "org/gnome/desktop/privacy" = {
          remember-recent-files = false;
        };
        "com/github/stunkymonkey/nautilus-open-any-terminal" = {
          terminal = "alacritty";
        };
      };
    };
  };
}
