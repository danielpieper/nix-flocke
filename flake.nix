{
  description = "Daniel's Nix/NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-secrets = {
      url = "git+ssh://git@github.com/danielpieper/nix-secrets.git?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    lanzaboote.url = "github:nix-community/lanzaboote";

    nixgl.url = "github:nix-community/nixGL";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    nix-index-database.url = "github:nix-community/nix-index-database";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:numtide/nixos-anywhere";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        disko.follows = "disko";
      };
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    comma = {
      url = "github:nix-community/comma";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };

    zjstatus.url = "github:dj95/zjstatus";

    poetry2nix.url = "github:nix-community/poetry2nix";
    authentik-nix.url = "github:nix-community/authentik-nix";

    catppuccin-obs = {
      url = "github:catppuccin/obs";
      flake = false;
    };

    teslamate = {
      url = "github:teslamate-org/teslamate/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazyvim = {
      url = "git+ssh://forgejo@forgejo.homelab.daniel-pieper.com/daniel/nvim.git";
      flake = false;
    };

    ventx = {
      url = "git+ssh://git@git.ventx.org/daniel/nix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    premiumizearr-nova = {
      # url = "git+ssh://forgejo@forgejo.homelab.daniel-pieper.com/daniel/premiumizearr-nova.git?ref=fixes";
      url = "github:ensingerphilipp/Premiumizearr-Nova";
      flake = false;
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-dns = {
      url = "github:Janik-Haag/nixos-dns";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    projecty = {
      url = "git+ssh://forgejo@forgejo.homelab.daniel-pieper.com/daniel/projecty.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    evitts = {
      url = "git+ssh://forgejo@forgejo.homelab.daniel-pieper.com/daniel/evitts.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tuxedo-nixos.url = "github:sund3RRR/tuxedo-nixos";

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-otbr = {
      url = "github:NixOS/nixpkgs/pull/332296/head";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;

        snowfall = {
          metadata = "flocke";
          namespace = "flocke";
          meta = {
            name = "flocke";
            title = "Daniel's Nix Flake";
          };
        };
      };
      dnsConfig = {
        inherit (inputs.self) nixosConfigurations;
        extraConfig = import "${inputs.nix-secrets}/dns";
      };
    in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
      };

      systems.modules.nixos = with inputs; [
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        lanzaboote.nixosModules.lanzaboote
        impermanence.nixosModules.impermanence
        sops-nix.nixosModules.sops
        authentik-nix.nixosModules.default
        teslamate.nixosModules.default
        nixos-dns.nixosModules.dns
        tuxedo-nixos.nixosModules.default
        niri.nixosModules.niri
        "${nixpkgs-otbr}/nixos/modules/services/home-automation/openthread-border-router.nix"
        inputs.noctalia.nixosModules.default
      ];

      systems.hosts = {
        tars.modules = with inputs; [
          nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen9-amd
          nixos-hardware.nixosModules.common-gpu-amd
        ];
      };

      # homes.modules = with inputs; [
      #   impermanence.nixosModules.home-manager.impermanence
      # ];

      overlays = with inputs; [
        nixgl.overlay
        nur.overlays.default
        llm-agents.overlays.default
      ];

      deploy = lib.mkDeploy { inherit (inputs) self; };

      # nix eval .#dnsDebugHost
      dnsDebugHost = inputs.nixos-dns.utils.debug.host inputs.self.nixosConfigurations.hal;

      # nix eval .#dnsDebugConfig
      dnsDebugConfig = inputs.nixos-dns.utils.debug.config dnsConfig;
    };
}
