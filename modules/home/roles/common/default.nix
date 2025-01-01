{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.roles.common;
in
{
  options.roles.common = {
    enable = lib.mkEnableOption "Enable common configuration";
  };

  config = lib.mkIf cfg.enable {
    browsers = {
      firefox.enable = true;
      google-chrome.enable = true;
      tor.enable = true;
    };

    system = {
      nix.enable = true;
    };

    cli = {
      terminals.foot.enable = true;
      terminals.kitty.enable = true;
      shells.fish.enable = true;
    };
    programs = {
      guis.enable = true;
      tuis.enable = true;
    };

    security = {
      sops.enable = true;
    };
    styles.stylix.enable = true;

    # TODO: move this to a separate module
    home.packages = with pkgs; [
      keymapp

      src-cli
      optinix

      (hiPrio parallel)
      moreutils
      nvtopPackages.amd
      unzip
      gnupg

      showmethekey
    ];
  };
}
