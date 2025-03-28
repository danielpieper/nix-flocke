{ config
, lib
, inputs
, ...
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
      # TODO: set in modules
      extraGroups =
        [
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
    } // cfg.extraOptions;

    sops.secrets.user-password = {
      sopsFile = "${inputs.nix-secrets}/sops/nixos.yaml";
      neededForUsers = true;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
