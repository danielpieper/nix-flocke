{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.programs.gpg;
in
{
  options.cli.programs.gpg = with types; {
    enable = mkBoolOpt false "Whether or not to enable gpg";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.seahorse
    ];

    services.gnome-keyring.enable = true;

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      sshKeys = [ inputs.nix-secrets.user.gpgKeyID ];
      pinentry.package = pkgs.pinentry-gnome3;
    };

    programs = {
      gpg = {
        enable = true;
        #homedir = "${config.xdg.dataHome}/gnupg";
      };
    };

    # systemd.user.sockets.gpg-agent = {
    #   listenStreams = let
    #     user = inputs.nix-secrets.user.name;
    #     socketDir =
    #       pkgs.runCommand "gnupg-socketdir" {
    #         nativeBuildInputs = [pkgs.python3];
    #       } ''
    #         python3 ${./gnupgdir.py} '/home/${user}/.local/share/gnupg' > $out
    #       '';
    #   in [
    #     "" # unset
    #     "%t/gnupg/${builtins.readFile socketDir}/S.gpg-agent"
    #   ];
    # };
  };
}
