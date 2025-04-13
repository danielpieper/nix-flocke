{
  inputs,
  pkgs,
  ...
}:
let
  dnsConfig = {
    inherit (inputs.self) nixosConfigurations;
    extraConfig = import "${inputs.nix-secrets}/dns";
  };
  generate = inputs.nixos-dns.utils.generate pkgs;
in

# nix build .#zonefiles
generate.zoneFiles dnsConfig
