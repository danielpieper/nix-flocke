{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.programs.zed-edit;
in
{
  options.programs.zed-edit = with types; {
    enable = mkBoolOpt false "Enable Zed Editor";
  };

  config = mkIf cfg.enable {
    stylix.targets.zed.enable = false;
    programs.zed-editor = {
      enable = true;
      extraPackages = with pkgs; [
        go
        gopls
        nil
        nixd
      ];
      extensions = [
        "docker-compose"
        "dockerfile"
        "html"
        "justfile"
        "make"
        "nix"
        "toml"
        "catppuccin"
      ];
      # userKeymaps = { };
      userSettings = {
        drag_and_drop_selection = {
          enabled = false;
        };
        project_panel = {
          starts_open = false;
          entry_spacing = "standard";
        };
        buffer_font_family = "JetBrainsMono Nerd Font";
        buffer_font_size = 17;
        buffer_font_weight = 400;
        current_line_highlight = "none";
        git = {
          inline_blame = {
            enabled = false;
          };
        };
        gutter = {
          folds = false;
          min_line_number_digits = 2;
        };
        hard_tabs = true;
        icon_theme = "JetBrains New UI Icons (Dark)";
        load_direnv = "shell_hook";
        lsp = {
          gopls = {
            initialization_options = {
              completeFunctionCalls = true;
              usePlaceholders = true;
            };
          };
        };
        show_whitespaces = "trailing";
        tab_size = 4;
        tabs = {
          file_icons = true;
        };
        telemetry = {
          metrics = false;
        };
        theme = {
          mode = "system";
          light = "Catppuccin Latte";
          dark = "Catppuccin Mocha";
        };
        toolbar = {
          breadcrumbs = false;
          quick_actions = false;
        };
        ui_font_family = "Inter Variable";
        ui_font_size = 16;
        vim_mode = true;
        buffer_line_height = {
          custom = 1.3;
        };
        terminal = {
          font_size = 14;
          copy_on_select = true;
          shell = {
            program = "fish";
          };
        };
        "theme_overrides" = {
          "Catppuccin Mocha" = {
            syntax = {
              comment = {
                color = "#516785";
                font_style = "italic";
                font_weight = null;
              };
              attribute = {
                color = "#E5C07B";
                font_style = null;
                font_weight = null;
              };
              constant = {
                color = "#E5C07B";
                font_style = null;
                font_weight = null;
              };
              constructor = {
                color = "#e56674";
                font_style = null;
                font_weight = null;
              };
              embedded = {
                color = "#a8b5d0";
                font_style = null;
                font_weight = null;
              };
              function = {
                color = "#74b3fb";
                font_style = null;
                font_weight = null;
              };
              keyword = {
                color = "#d49ff4";
                font_style = null;
                font_weight = null;
              };
              number = {
                color = "#E5C07B";
                font_style = null;
                font_weight = null;
              };
              operator = {
                color = "#59f2f7";
                font_style = null;
                font_weight = null;
              };
              property = {
                color = "#59f2f7";
                font_style = null;
                font_weight = null;
              };
              string = {
                color = "#70F49C";
                font_style = null;
                font_weight = null;
              };
              "string.escape" = {
                color = "#59f2f7";
                font_style = null;
                font_weight = null;
              };
              "string.regex" = {
                color = "#70F49C";
                font_style = null;
                font_weight = null;
              };
              "string.special" = {
                color = "#59f2f7";
                font_style = null;
                font_weight = null;
              };
              "string.special.symbol" = {
                color = "#59f2f7";
                font_style = null;
                font_weight = null;
              };
              tag = {
                color = "#e56674";
                font_style = null;
                font_weight = null;
              };
              "text.literal" = {
                color = "#70F49C";
                font_style = null;
                font_weight = null;
              };
              type = {
                color = "#E5C07B";
                font_style = null;
                font_weight = null;
              };
              variable = {
                color = "#e56674";
                font_style = null;
                font_weight = null;
              };
              "variable.special" = {
                color = "#E5C07B";
                font_style = null;
                font_weight = null;
              };
              boolean = {
                color = "#E5C07B";
                font_style = null;
                font_weight = null;
              };
              variant = {
                color = null;
                font_style = null;
                font_weight = null;
              };
            };
          };
        };
      };
      # userTasks = { };
    };
  };
}
