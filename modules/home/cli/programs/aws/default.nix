{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.programs.aws;
in
{
  options.cli.programs.aws = with types; {
    enable = mkBoolOpt false "Whether or not to enable aws cli";
  };

  config = mkIf cfg.enable {
    programs.awscli = {
      enable = true;
    };

    home.packages = with pkgs; [
      awslogs # AWS CloudWatch logs for Humans
      aws-vault # A vault for securely storing and accessing AWS credentials in development environments
    ];
  };
}
