{ config
, lib
, ...
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
      ports = [ 22 ];

      settings = {
        PasswordAuthentication = false;
        # PermitRootLogin = "no";
        StreamLocalBindUnlink = "yes";
        GatewayPorts = "clientspecified";
      };
    };

    users.users = {
      ${config.user.name}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQe6KSxEplb0f4Aw/UO0x5CLfDp9gvtJ6Bky/x0nGXB 1password"
      ];
    };

    # Passwordless sudo when SSH'ing with keys
    security.pam.sshAgentAuth.enable = true;
  };
}
