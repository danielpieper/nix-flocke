{
  config,
  lib,
  inputs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.user;
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  options.user = with types; {
    name = mkOpt str "daniel" "The name of the user's account";
    extraGroups = mkOpt (listOf str) [ ] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs { } "Extra options passed to users.users.<name>";
  };

  config = {
    users.mutableUsers = false;
    users.users.${cfg.name} = {
      isNormalUser = true;
      inherit (cfg) name;
      home = "/home/${cfg.name}";
      group = "users";
      hashedPasswordFile = config.sops.secrets.user-password.path;
      # initialPassword = "1235";
      # TODO: set in modules
      extraGroups = [
        "wheel"
        "audio"
        "sound"
        "video"
        "input"
        "tty"
      ]
      ++ ifTheyExist [
        "networkmanager"
        "podman"
        "git"
        "libvirtd"
        "kvm"
      ]
      ++ cfg.extraGroups;
    }
    // cfg.extraOptions;

    sops.secrets.user-password = {
      sopsFile = "${inputs.nix-secrets}/sops/nixos.yaml";
      neededForUsers = true;
    };

    # security = {
    #   sudo = {
    #     wheelNeedsPassword = false;
    #     # Only allow members of the wheel group to execute sudo by setting the executable’s permissions accordingly. This prevents users that are not members of wheel from exploiting vulnerabilities in sudo such as CVE-2021-3156.
    #     execWheelOnly = true;
    #     # Don't lecture the user. Less mutable state.
    #     extraConfig = ''
    #       Defaults lecture = never
    #     '';
    #   };
    # };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
