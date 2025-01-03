{
  config,
  lib,
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
      age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
