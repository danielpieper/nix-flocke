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
      package = pkgs.zed-editor-fhs;
      extraPackages = with pkgs; [
        go
        gopls
      ];
      extensions = [
        "nix"
        "toml"
        "make"
        "justfile"
        "dockerfile"
        "docker-compose"
        "html"
      ];
      # themes = { };
      # userKeymaps = { };
      userSettings = {
        icon_theme = "Catppuccin Mocha";
        telemetry = {
          metrics = false;
        };
        vim_mode = true;
        buffer_font_family = "JetBrainsMono Nerd Font";
        buffer_font_size = 17;
        buffer_font_weight = 400;
        buffer_line_height = {
          custom = 1.4;
        };
        theme = "One Dark Pro";
        ui_font_family = "Inter Variable";
        ui_font_size = 16;
        gutter = {
          folds = false;
          min_line_number_digits = 2;
        };
        show_whitespaces = "trailing";
        load_direnv = "shell_hook";
        toolbar = {
          breadcrumbs = false;
          quick_actions = false;
        };
        tabs = {
          file_icons = true;
        };
        git = {
          inline_blame = {
            enabled = false;
          };
        };
        current_line_highlight = "none";
        tab_size = 4;
        hard_tabs = true;
        lsp = {
          gopls = {
            initialization_options = {
              usePlaceholders = true;
              completeFunctionCalls = true;
            };
          };
        };
      };
      # userTasks = { };
    };
  };
}
