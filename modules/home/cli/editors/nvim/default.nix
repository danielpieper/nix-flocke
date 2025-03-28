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
      # ensure init.lua is not written by home manager:
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
        golangci-lint-langserver

        # Nix
        nil
        nixfmt-rfc-style

        # Terraform
        terraform
        terraform-ls
        tflint

        # Helm
        kubernetes-helm
        helm-ls

        ansible

        # Python
        pyright
        ruff

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
      };
      intelephenseLicenceKey = {
        path = "${config.xdg.configHome}/intelephense/license.txt";
      };
    };

    xdg.configFile =
      let
        nvim-spell-de-utf8-dictionary = builtins.fetchurl {
          url = "https://www.mirrorservice.org/pub/vim/runtime/spell/de.utf-8.spl";
          sha256 = "1ld3hgv1kpdrl4fjc1wwxgk4v74k8lmbkpi1x7dnr19rldz11ivk";
        };

        nvim-spell-de-utf8-suggestions = builtins.fetchurl {
          url = "https://www.mirrorservice.org/pub/vim/runtime/spell/de.utf-8.sug";
          sha256 = "0j592ibsias7prm1r3dsz7la04ss5bmsba6l1kv9xn3353wyrl0k";
        };

        nvim-spell-de-latin1-dictionary = builtins.fetchurl {
          url = "https://www.mirrorservice.org/pub/vim/runtime/spell/de.latin1.spl";
          sha256 = "0hn303snzwmzf6fabfk777cgnpqdvqs4p6py6jjm58hdqgwm9rw9";
        };

        nvim-spell-de-latin1-suggestions = builtins.fetchurl {
          url = "https://www.mirrorservice.org/pub/vim/runtime/spell/de.latin1.sug";
          sha256 = "0mz07d0a68fhxl9vmy1548vnbayvwv1pc24zhva9klgi84gssgwm";
        };
      in
      {
        "nvim/lua".source = "${inputs.lazyvim}/lua";
        "nvim/spell/de.utf-8.spl".source = nvim-spell-de-utf8-dictionary;
        "nvim/spell/de.utf-8.sug".source = nvim-spell-de-utf8-suggestions;
        "nvim/spell/de.latin1.spl".source = nvim-spell-de-latin1-dictionary;
        "nvim/spell/de.latin1.sug".source = nvim-spell-de-latin1-suggestions;
      };
  };
}
