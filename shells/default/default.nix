{
  pkgs,
  inputs,
  system,
  ...
}:
pkgs.mkShell {
  inherit (inputs.self.checks.${system}.pre-commit) shellHook;
  buildInputs = inputs.self.checks.${system}.pre-commit.enabledPackages;

  NIX_CONFIG = "extra-experimental-features = nix-command flakes";

  packages = with pkgs; [
    nh
    inputs.nixos-anywhere.packages.${pkgs.system}.nixos-anywhere
    python312Packages.mkdocs-material
    deploy-rs
    just

    octodns
    octodns-providers.bind
    octodns-providers.hetzner
    # TODO: https://github.com/NixOS/nixpkgs/issues/398191
    # (octodns.withProviders (ps: [
    #   octodns-providers.bind
    #   octodns-providers.hetzner
    # ]))

    alejandra
    home-manager
    git
    sops
    ssh-to-age
    gnupg
    age
  ];
}
