{ config
, lib
, inputs
, ...
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

  imports = with inputs; [
    sops-nix.homeManagerModules.sops
  ];

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = "${inputs.nix-secrets}/sops/home.yaml";
      validateSopsFiles = false;
      age = {
        generateKey = true;
        keyFile = "/home/${config.flocke.user.name}/.config/sops/age/keys.txt";
        sshKeyPaths = [ "/home/${config.flocke.user.name}/.ssh/id_ed25519" ];
      };
    };
  };
}
