{ pkgs }:

# TODO: Remove when https://github.com/NixOS/nixpkgs/issues/370185 is resolved

let
  cloudflare-go = pkgs.callPackage ./cloudflare-go.nix { };
in
pkgs.cloudflared.overrideAttrs (oldAttrs: {
  buildInputs = [ cloudflare-go ];
  buildPhase = ''
    export GOROOT=${cloudflare-go}/share/go
    export PATH=$GOROOT/bin:$PATH
    ${oldAttrs.buildPhase or ""}
  '';
})
