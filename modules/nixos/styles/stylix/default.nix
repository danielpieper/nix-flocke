{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.styles.stylix;
  flavor = if cfg.dark then "mocha" else "latte";
  polarity = if cfg.dark then "dark" else "light";
in
{
  options.styles.stylix = {
    enable = lib.mkEnableOption "Enable stylix";
    dark = lib.mkOption {
      type = lib.types.bool;
      description = "Use dark polarity";
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;

      fontconfig = {
        enable = true;
        localConf = ''
          <alias>
            <family>monospace</family>
            <prefer><family>Symbols Nerd Font</family></prefer>
          </alias>
        '';
      };
    };

    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${flavor}.yaml";
      polarity = lib.mkDefault polarity;
      homeManagerIntegration.autoImport = false;
      homeManagerIntegration.followSystem = false;
      targets.nixvim.enable = false;

      image = pkgs.flocke.wallpapers.earth;

      cursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };

      fonts = {
        sizes = {
          terminal = 14;
          applications = 12;
          popups = 12;
        };

        serif = {
          name = "Source Serif";
          package = pkgs.source-serif;
        };

        sansSerif = {
          name = "Inter Variable";
          package = pkgs.inter;
        };

        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };

        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
