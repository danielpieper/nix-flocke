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

# nix build .#octodns
generate.octodnsConfig {
  inherit dnsConfig;
  config = {
    providers = {
      hetzner = {
        class = "octodns_hetzner.HetznerProvider";
        token = "env/HETZNER_DNS_API";
      };
    };
  };
  zones = {
    "${inputs.nix-secrets.domain}." = inputs.nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
  };
}
