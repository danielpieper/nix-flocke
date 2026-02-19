{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.system.nix;
in
{
  options.system.nix = with types; {
    enable = mkBoolOpt false "Whether or not to manage nix configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nixgl.nixGLIntel
      nix-output-monitor
      nvd
    ];

    systemd.user.startServices = "sd-switch";

    programs = {
      home-manager.enable = true;
    };

    home.sessionVariables = {
      FLAKE = "/home/${config.flocke.user.name}/Projects/nix-flocke";
    };

    nix = {
      settings = {
        trusted-substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://numtide.cachix.org?priority=42"
          "https://niri.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        ];

        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
        use-xdg-base-directories = true;
      };
    };

    news = {
      display = "silent";
      json = lib.mkForce { };
      entries = lib.mkForce [ ];
    };
  };
}
