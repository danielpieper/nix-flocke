{ pkgs
, config
, lib
, ...
}:
with lib;
let
  cfg = config.services.flocke.forgejo;
in
{
  options.services.flocke.forgejo = {
    enable-runner = mkEnableOption "Enable Forgejo runner";
  };

  config = mkIf cfg.enable-runner {
    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.default = {
        enable = true;
        name = "hal";
        url = "http://127.0.0.1:3083";
        # Obtaining the path to the runner token file may differ
        # tokenFile should be in format TOKEN=<secret>, since it's EnvironmentFile for systemd
        tokenFile = config.sops.secrets.forgejo-runner-token.path;
        settings = {
          log.level = "warn";
        };
        labels = [
          "ubuntu-latest:docker://node:16-bullseye"
          "ubuntu-22.04:docker://node:16-bullseye"
          "ubuntu-20.04:docker://node:16-bullseye"
          "ubuntu-18.04:docker://node:16-buster"
          ## optionally provide native execution on the host:
          # "native:host"
        ];
      };
    };

    services.flocke.virtualisation.podman.enable = true;

    sops.secrets.forgejo-runner-token.owner = config.services.forgejo.user;
  };
}
