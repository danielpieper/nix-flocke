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
            hostname = lib.mkOption {
              type = lib.types.str;
              description = "The hostname or IP address of the SSH host.";
            };
            identityFile = lib.mkOption {
              type = lib.types.str;
              description = "The path to the identity file for the SSH host.";
            };
            identitiesOnly = lib.mkOption {
              type = lib.types.bool;
              description = "Only allow the specified identities for the SSH host.";
            };
          };
        }
      );
      default = { };
      description = "A set of extra SSH hosts.";
      example = literalExample ''
        {
          "gitlab-personal" = {
            hostname = "gitlab.com";
            identityFile = "~/.ssh/id_ed25519_personal";
            identitiesOnly = true;
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = inputs.nix-secrets.ssh.matchBlocks // cfg.extraHosts;
    };
  };
}
