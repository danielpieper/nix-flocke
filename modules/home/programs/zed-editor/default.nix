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
  themeConfig = import ./theme.nix;
  keyMapConfig = import ./keymap.nix;
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
      userKeymaps = keyMapConfig;
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
      }
      // themeConfig;
      # userTasks = { };
    };
  };
}
