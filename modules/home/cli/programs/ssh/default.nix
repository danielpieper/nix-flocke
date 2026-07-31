{
  inputs,
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.programs.ssh;
in
{
  options.cli.programs.ssh = with types; {
    enable = mkBoolOpt false "Whether or not to enable ssh";

    extraHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            HostName = lib.mkOption {
              type = lib.types.str;
              description = "The hostname or IP address of the SSH host.";
            };
            IdentityFile = lib.mkOption {
              type = lib.types.str;
              description = "The path to the identity file for the SSH host.";
            };
            IdentitiesOnly = lib.mkOption {
              type = lib.types.bool;
              description = "Only allow the specified identities for the SSH host.";
            };
          };
        }
      );
      default = { };
      description = ''
        A set of extra SSH hosts. Keys are OpenSSH directive names, as
        expected by `programs.ssh.settings`.
      '';
      example = literalExample ''
        {
          "gitlab-personal" = {
            HostName = "gitlab.com";
            IdentityFile = "~/.ssh/id_ed25519_personal";
            IdentitiesOnly = true;
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = inputs.nix-secrets.ssh.settings // cfg.extraHosts;
    };
  };
}
