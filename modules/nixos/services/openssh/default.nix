{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.services.ssh;
in
{
  options.services.ssh = with types; {
    enable = mkBoolOpt false "Enable ssh";
    authorizedKeys = mkOpt (listOf str) [ ] "The public keys to apply.";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ inputs.nix-secrets.networking.ports.tcp.ssh ];

      settings = {
        PasswordAuthentication = false;
        # PermitRootLogin = "no";
        StreamLocalBindUnlink = "yes";
        GatewayPorts = "clientspecified";
      };
    };

    users.users = {
      ${config.user.name}.openssh.authorizedKeys.keys = [
        inputs.nix-secrets.user.pubKey
      ];
    };

    # Passwordless sudo when SSH'ing with keys
    security.pam.sshAgentAuth.enable = true;
  };
}
