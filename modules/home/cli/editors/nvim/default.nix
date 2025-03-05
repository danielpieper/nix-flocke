{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
with lib;
with lib.flocke;
with inputs;
let
  cfg = config.cli.editors.nvim;
in
{
  options.cli.editors.nvim = with types; {
    enable = mkBoolOpt false "enable neovim editor";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      defaultEditor = true;
      # ensure init.lua is not writte by home manager:
      plugins = lib.mkForce [ ];
      extraPackages = with pkgs; [
        # Avante/ Treesitter
        gcc
        gnumake

        lazygit
        stylua
        fd
        rust-analyzer
        tree-sitter
        nodejs
        pgformatter
        marksman
        sqlfluff
        vtsls
        # Golang:
        go-tools
        gotools
        gopls
        gofumpt
        delve # debugger
        gomodifytags
        impl
        golangci-lint

        # Nix
        nil
        nixfmt-rfc-style

        # Terraform
        terraform
        terraform-ls
        tflint

        markdownlint-cli2
        nodePackages.bash-language-server
        nodePackages.dockerfile-language-server-nodejs
        nodePackages.vscode-langservers-extracted
        nodePackages.vscode-json-languageserver
        nodePackages.typescript-language-server
        nodePackages.typescript
        nodePackages.yaml-language-server
        nodePackages.vim-language-server
        # nodePackages.vue-language-server
        nodePackages.intelephense
        nodePackages."@tailwindcss/language-server"
        nodePackages.tailwindcss
        sumneko-lua-language-server
      ];
    };

    sops.secrets = {
      neovim-init = {
        path = "${config.xdg.configHome}/nvim/init.lua";
        sopsFile = ../../../secrets.yaml;
      };
      intelephenseLicenceKey = {
        path = "${config.xdg.configHome}/intelephense/license.txt";
        sopsFile = ../../../secrets.yaml;
      };
    };

    xdg.configFile."nvim/lua" = {
      source = "${inputs.lazyvim}/lua";
    };
  };
}
