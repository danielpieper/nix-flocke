{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.styles.stylix;
in
{
  options.styles.stylix = {
    enable = lib.mkEnableOption "Enable stylix";
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;
      packages = with pkgs; [
        nerd-fonts.symbols-only
      ];

      fontconfig = {
        localConf = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
              <alias binding="weak">
                  <family>monospace</family>
                  <prefer>
                      <family>emoji</family>
                  </prefer>
              </alias>
              <alias binding="weak">
                  <family>sans-serif</family>
                  <prefer>
                      <family>emoji</family>
                  </prefer>
              </alias>
              <alias binding="weak">
                  <family>serif</family>
                  <prefer>
                      <family>emoji</family>
                  </prefer>
              </alias>
          </fontconfig>
        '';
      };
    };

    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      # https://pltanton.dev/posts/2024/02/nix-based-dark-light-theme-switch/
      polarity = lib.mkDefault "dark";
      homeManagerIntegration.autoImport = false;
      homeManagerIntegration.followSystem = false;

      image = pkgs.flocke.wallpapers.earth;

      cursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };

      fonts = {
        sizes = {
          terminal = 12;
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
