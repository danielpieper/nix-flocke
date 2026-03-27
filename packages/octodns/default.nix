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
        backend = "hcloud";
        token = "env/HETZNER_CLOUD_TOKEN";
      };
    };
  };
  zones = {
    "${inputs.nix-secrets.domain}." = inputs.nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
    "${inputs.nix-secrets.homelabDomain}." = inputs.nixos-dns.utils.octodns.generateZoneAttrs [
      "hetzner"
    ];
  };
}
