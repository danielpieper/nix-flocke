{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.programs.podman;
in
{
  options.cli.programs.podman = with types; {
    enable = mkBoolOpt false "Whether or not to manage podman";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      arion
      podman
      podman-compose
      podman-tui
      amazon-ecr-credential-helper
    ];
  };
}
