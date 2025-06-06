{
  config,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.roles.desktop.addons._1password;
  onePassPath = "~/.1password/agent.sock";
  username = config.user.name;
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
    };

    programs.ssh.extraConfig = ''
      IdentityAgent ${onePassPath}
    '';

    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          zen
        '';
        mode = "0755";
      };
    };
  };
}
