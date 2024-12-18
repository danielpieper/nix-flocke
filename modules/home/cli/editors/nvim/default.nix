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
  nvimConfig = pkgs.fetchFromGitea {
    domain = "codeberg.org";
    owner = "naseschief";
    repo = "nvim";
    rev = "d144538e8333f730a9406bf2616fb8ef1812991f";
    sha256 = "sha256-maVQpqUTSH7jiIysI9TE13qTTPyQsbxLaLbQoEclZSg=";

    postFetch = ''
      cp -vaR "$out/lua/." "$out"
      rm -rf "$out/lua"
    '';
  };
in
{
  options.cli.editors.nvim = with types; {
    enable = mkBoolOpt false "enable neovim editor";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
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

    home = {
      file."${config.xdg.configHome}/nvim/lua".source = nvimConfig;

      packages = with pkgs; [
        neovim
        lazygit
        nil
        nixpkgs-fmt
        stylua
        fd
        rust-analyzer
        ktlint
        tree-sitter
        nodejs
        pgformatter
        marksman
        sqlfluff
        vtsls
        markdownlint-cli
        nodePackages.eslint
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

      # sessionVariables = {
      #   EDITOR = "nvim";
      #   VISUAL = "nvim";
      # };
    };
  };
}
