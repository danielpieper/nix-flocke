{ inputs, ... }:
_: prev: {
  zjstatus = inputs.zjstatus.packages.${prev.system}.default;
}
