{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.security.sops;
in
{
  options.security.sops = with types; {
    enable = mkBoolOpt false "Whether to enable sop for secrets management.";
  };

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = "${inputs.nix-secrets}/sops/services.yaml";
      validateSopsFiles = false;

      # automatically import host SSH keys as age keys
      age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
      # secrets will be output to /run/secrets
      # e.g. /run/secrets/msmtp-password
      # secrets required for user creation are handled in respective ./modules/nixos/user/default.nix files
      # because they will be output to /run/secrets-for-users and only when the user is assigned to a host.
    };
  };
}
