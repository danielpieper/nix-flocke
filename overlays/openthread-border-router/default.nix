{ inputs, ... }:
_: prev:
let
  inherit (inputs.nixpkgs-otbr.legacyPackages.${prev.stdenv.hostPlatform.system})
    openthread-border-router
    ;
in
{
  inherit openthread-border-router;
}
