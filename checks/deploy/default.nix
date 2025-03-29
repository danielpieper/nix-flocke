{
  inputs,
  system,
  ...
}:

inputs.deploy-rs.lib.${system}.deployChecks inputs.self.deploy
