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
    stylix.url = "github:nix-community/stylix";
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

    hypr-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprcursor = {
      url = "github:hyprwm/Hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };

    zjstatus.url = "github:dj95/zjstatus";

    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    poetry2nix.url = "github:nix-community/poetry2nix";
    authentik-nix.url = "github:nix-community/authentik-nix";

    catppuccin-obs = {
      url = "github:catppuccin/obs";
      flake = false;
    };

    teslamate = {
      # url = "github:teslamate-org/teslamate?rev=0ec408c8e182fe64e9568b6f137cbfb528717e8e"; # v1.32.0
      # TODO: until deps hash is updated upstream
      url = "github:danielpieper/teslamate";
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
      url = "git+ssh://forgejo@forgejo.homelab.daniel-pieper.com/daniel/premiumizearr-nova.git?ref=fixes";
      flake = false;
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-dns = {
      url = "github:Janik-Haag/nixos-dns";
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
        nix-topology.nixosModules.default
        authentik-nix.nixosModules.default
        teslamate.nixosModules.default
        nixos-dns.nixosModules.dns
      ];

      systems.hosts = {
        tars.modules = with inputs; [ nixos-hardware.nixosModules.lenovo-thinkpad-x1-9th-gen ];
        case.modules = with inputs; [ nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1 ];
      };

      homes.modules = with inputs; [
        zen-browser.homeModules.default
        #   impermanence.nixosModules.home-manager.impermanence
      ];

      overlays = with inputs; [
        nixgl.overlay
        nur.overlays.default
        nix-topology.overlays.default
      ];

      deploy = lib.mkDeploy { inherit (inputs) self; };

      # nix eval .#dnsDebugHost
      dnsDebugHost = inputs.nixos-dns.utils.debug.host inputs.self.nixosConfigurations.hal;

      # nix eval .#dnsDebugConfig
      dnsDebugConfig = inputs.nixos-dns.utils.debug.config dnsConfig;

      topology =
        with inputs;
        let
          host = self.nixosConfigurations.${builtins.head (builtins.attrNames self.nixosConfigurations)};
        in
        import nix-topology {
          inherit (host) pkgs; # Only this package set must include nix-topology.overlays.default
          modules = [
            (import "${inputs.nix-secrets}/topology" {
              inherit (host) config;
            })
            { inherit (self) nixosConfigurations; }
          ];
        };
    };
}
