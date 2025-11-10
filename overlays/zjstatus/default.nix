{ inputs, ... }:
_: prev: {
  zjstatus = inputs.zjstatus.packages.${prev.stdenv.hostPlatform.system}.default;
}
