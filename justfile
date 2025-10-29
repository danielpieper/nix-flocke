# vim: set ft=make :
# https://github.com/casey/just#quick-start

# List available targets
help:
	@just --list

# Run checks
check:
	nix flake check

# Create installer iso (minimal or graphical)
iso version="minimal":
  nix build .#install-isoConfigurations.{{version}}

# Deploy to remote server i.e. Home Lab (using SSH)
deploy server:
  nix shell nixpkgs/nixos-24.11#nix --command deploy .#{{server}} --hostname {{server}} --ssh-user nixos --remote-build

# Deploy on boot my to remote server i.e. Home Lab (using SSH)
deployboot server:
  nix shell nixpkgs/nixos-24.11#nix --command deploy .#{{server}} --hostname {{server}} --ssh-user nixos --remote-build --boot
  # nix shell nixpkgs/nixos-24.11#nix --command deploy .#{{server}} --hostname {{server}} --ssh-user nixos --remote-build --boot --log-format internal-json -v |& nom --json

# Apply host config
apply:
  nh os switch

# Build Home Lab diagram using nix-topology
topology:
	nix build .#topology.config.output
	# xdg-open  {{justfile_directory()}}/result/main.svg

dns:
	nix build .#octodns
	OP_SERVICE_ACCOUNT_TOKEN="" HETZNER_DNS_API=$(op read "op://Private/Hetzner/octodns api token") octodns-sync --config-file=./result
	@read -p "apply? (y/N): " answer && [ "$answer" = "y" ] && OP_SERVICE_ACCOUNT_TOKEN="" HETZNER_DNS_API=$(op read "op://Private/Hetzner/octodns api token") octodns-sync --config-file=./result --doit || echo "Skipped applying changes"
