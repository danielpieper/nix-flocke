{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.styles.stylix;
  flavor = if cfg.dark then "mocha" else "latte";
  polarity = if cfg.dark then "dark" else "light";
in
{
  imports = with inputs; [
    stylix.homeModules.stylix
    catppuccin.homeModules.catppuccin
  ];

  options.styles.stylix = {
    enable = lib.mkEnableOption "Enable stylix";
    dark = lib.mkOption {
      type = lib.types.bool;
      description = "Use dark polarity";
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.jetbrains-mono
      inter
      open-sans
    ];

    # Stylix's cursor target defines `home.pointerCursor` without an explicit
    # `enable`, which home-manager now warns about. Opt in ourselves.
    home.pointerCursor.enable = true;

    # TODO: Possible to use stylix instead?
    catppuccin = {
      # `enable` is the global toggle; `autoEnable` would enroll every port.
      # Keep enrolling opt-in — only the ports listed below are themed here.
      enable = true;
      autoEnable = false;
      inherit flavor;
      fish.enable = true;
    };

    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${flavor}.yaml";
      polarity = lib.mkDefault polarity;
      targets.nixvim.enable = false;

      icons = {
        enable = true;
        package = pkgs.catppuccin-papirus-folders.override {
          flavor = if cfg.dark then "mocha" else "latte";
          accent = "lavender";
        };
        dark = "Papirus-Dark";
        light = "Papirus-Light";
      };

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
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
