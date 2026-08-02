{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.flocke) mkBoolOpt;

  cfg = config.system.boot;
in
{
  options.system.boot = {
    enable = mkBoolOpt false "Whether or not to enable booting.";
    plymouth = mkBoolOpt false "Whether or not to enable plymouth boot splash.";
    secureBoot = mkBoolOpt false "Whether or not to enable secure boot.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        efibootmgr
        # TODO: remove comment when build succeeds
        # efitools
        efivar
        fwupd
      ]
      ++ lib.optionals cfg.secureBoot [ sbctl ];

    boot = {
      kernelParams = lib.optionals cfg.plymouth [
        "quiet"
        "splash"
        "loglevel=3"
        "udev.log_level=0"
      ];
      initrd.verbose = !cfg.plymouth;
      consoleLogLevel = lib.mkIf cfg.plymouth 0;
      initrd.systemd.enable = true;

      lanzaboote = mkIf cfg.secureBoot {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };

      loader = {
        efi = {
          canTouchEfiVariables = true;
        };

        systemd-boot = {
          enable = !cfg.secureBoot;
          # 20 kernel+initrd sets never fit a 511M ESP — each aarch64 pair is
          # ~45M, so ava filled up and a deploy died with ENOSPC while
          # systemd-boot staged the new entry. 5 leaves comfortable headroom.
          configurationLimit = 5;
          editor = false;
        };
      };

      plymouth = {
        enable = cfg.plymouth;
      };
    };

    services.fwupd.enable = true;
  };
}
