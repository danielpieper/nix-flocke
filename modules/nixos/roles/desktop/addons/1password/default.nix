{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.roles.desktop.addons._1password;
  username = config.user.name;
  onePassPath = "/home/${username}/.1password/agent.sock";
in
{
  options.roles.desktop.addons._1password = {
    enable = mkBoolOpt false "Enable 1Password";
  };

  config = mkIf cfg.enable {
    programs = {
      _1password.enable = true;
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [ username ];
      };
      ssh.extraConfig = ''
        Host *
           IdentityAgent ${onePassPath}
      '';
    };

    environment = {
      variables.SSH_AUTH_SOCK = onePassPath;
      etc = {
        "1password/custom_allowed_browsers" = {
          text = ''
            zen
          '';
          mode = "0755";
        };
      };
    };
  };
}
