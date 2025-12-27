# nix-flocke - AI Assistant Documentation

This file provides comprehensive documentation about the nix-flocke project for AI assistants like Claude.

## 1. Project Overview

**nix-flocke** is Daniel Pieper's personal NixOS configuration repository, managing multiple machines using Nix Flakes and modern NixOS tooling. It serves as a declarative, version-controlled infrastructure-as-code setup for both personal workstations and home lab servers.

### Managed Hosts

The repository manages 5 distinct machines:
- **tars** - Tuxedo InfinityBook Pro14 (AMD laptop, x86_64)
- **case** - Lenovo ThinkPad T14 Gen1 (AMD laptop, x86_64)
- **ava** - Lenovo ThinkPad X250 (older laptop, x86_64)
- **hal** - Homelab server (x86_64)
- **jarvis** - ARM64 server (aarch64-linux)

### Key Technologies

- **Nix Flakes** - Modern dependency management and reproducible builds
- **Snowfall Lib** - Structured flake framework for organized configurations
- **NixOS** - Declarative Linux distribution
- **Home Manager** - User environment and dotfile management
- **Disko** - Declarative disk partitioning
- **Impermanence** - Opt-in state persistence with ephemeral root
- **sops-nix** - Encrypted secrets management

### Key Features

- Modular configuration structure with reusable components
- Multiple desktop environments (Hyprland, Niri, GNOME)
- Comprehensive home lab services (Traefik, Jellyfin, PostgreSQL, Home Assistant, etc.)
- Encrypted BTRFS partitions with automatic snapshots
- Unified theming with Catppuccin and Stylix
- Hardware-specific optimizations using nixos-hardware
- Custom packages and overlays
- Secure boot support with lanzaboote

## 2. Directory Structure

```
nix-flocke/
├── flake.nix                    # Main flake definition (Snowfall Lib based)
├── flake.lock                   # Dependency lock file
├── README.md                    # Project documentation
├── justfile                     # Just recipes for common tasks
├── claude.md                    # This file - AI assistant documentation
│
├── modules/                     # Reusable NixOS and Home Manager modules
│   ├── nixos/                   # System-level modules
│   │   ├── cli/                 # CLI programs (btop, nh, nix-ld)
│   │   ├── hardware/            # Hardware configs (audio, bluetooth, networking, GPU)
│   │   ├── roles/               # Role definitions (desktop, server, common)
│   │   ├── security/            # Security modules (sops, doas, yubikey)
│   │   ├── services/            # System services
│   │   ├── styles/              # Visual styling (stylix)
│   │   └── systems/             # System configs (boot, impermanence, locale, nix)
│   └── home/                    # User-level modules
│       ├── browsers/            # Firefox, Chrome, Tor
│       ├── cli/                 # Shell tools (nvim, tmux, zellij, atuin, bat, eza, etc.)
│       ├── desktops/            # Desktop environments
│       ├── programs/            # User programs
│       ├── roles/               # User roles
│       ├── security/            # User security
│       ├── services/            # User services
│       ├── styles/              # User styling
│       └── user/                # User account configuration
│
├── systems/                     # Host-specific configurations
│   ├── x86_64-linux/            # x86_64 architecture hosts
│   │   ├── tars/                # Tuxedo laptop config
│   │   ├── case/                # ThinkPad T14 config
│   │   ├── ava/                 # ThinkPad X250 config
│   │   └── hal/                 # Homelab server config
│   ├── aarch64-linux/           # ARM64 architecture hosts
│   │   └── jarvis/              # ARM64 server config
│   └── x86_64-install-iso/      # Custom installation ISOs
│       ├── minimal/             # Minimal installer
│       └── graphical/           # Graphical installer
│
├── packages/                    # Custom Nix packages
│   ├── matter-server-js/        # Matter.js controller for Home Assistant
│   ├── n8n/                     # N8N automation platform
│   ├── octodns/                 # DNS management tool
│   ├── dim/                     # Custom utility
│   ├── premiumizarr-nova/       # Custom utility
│   ├── wallpapers/              # Custom wallpapers
│   └── zonefiles/               # DNS zone files
│
├── overlays/                    # Package overlays
│   ├── openthread-border-router/  # OpenThread Border Router overlay
│   └── zjstatus/                # Zellij status bar overlay
│
├── homes/                       # Home Manager configurations
│   └── x86_64-linux/            # Per-user home configurations
│
├── lib/                         # Library functions and utilities
├── shells/                      # Development shells
└── checks/                      # Pre-commit and quality checks
```

## 3. Module Organization

### NixOS Modules (`modules/nixos/`)

System-level configuration modules that define services, hardware support, and system behavior.

**Directory structure:**
- **`cli/`** - Command-line interface programs
  - `btop/` - System monitor configuration
  - `nh/` - Nix helper tool
  - `nix-ld/` - Dynamic linker for unpatched binaries

- **`hardware/`** - Hardware-specific configurations
  - `audio/` - Audio system setup (PipeWire)
  - `bluetooth/` - Bluetooth configuration
  - `dygma/` - Dygma keyboard support
  - `gpu/` - GPU configuration (AMD, Intel, NVIDIA)
  - `logitech/` - Logitech device support
  - `networking/` - Network configuration

- **`roles/`** - System role definitions
  - `common/` - Shared configuration for all systems
  - `desktop/` - Desktop environment setup
  - `server/` - Headless server configuration

- **`security/`** - Security-related modules
  - `ausweisapp/` - German ID card authentication
  - `doas/` - sudo alternative
  - `sops/` - Secrets management
  - `yubikey/` - YubiKey support

- **`services/`** - System services
  - `home-assistant/` - Home automation platform
  - `traefik/` - Reverse proxy
  - `postgres/` - PostgreSQL database
  - `jellyfin/` - Media server
  - `navidrome/` - Music streaming
  - `authentik/` - SSO and authentication
  - `monitoring/` - Prometheus + Grafana
  - And many more...

- **`styles/`** - Visual styling
  - `stylix/` - System-wide theming

- **`systems/`** - Core system configuration
  - `boot/` - Bootloader and secure boot
  - `impermanence/` - Ephemeral root filesystem
  - `locale/` - Timezone and localization
  - `nix/` - Nix daemon configuration

### Home Manager Modules (`modules/home/`)

User-level configuration modules for applications and dotfiles.

**Directory structure:**
- **`browsers/`** - Web browsers
  - `firefox/`, `chrome/`, `tor/`

- **`cli/`** - Command-line tools
  - `nvim/` - Neovim editor
  - `tmux/` - Terminal multiplexer
  - `zellij/` - Modern terminal workspace
  - `atuin/` - Shell history sync
  - `bat/` - Cat clone with syntax highlighting
  - `bottom/` - System monitor
  - `direnv/` - Environment switcher
  - `eza/` - Modern ls replacement
  - `fzf/` - Fuzzy finder
  - `git/` - Git configuration
  - `starship/` - Shell prompt
  - `zoxide/` - Smarter cd command
  - And many more...

- **`desktops/`** - Desktop environment configurations
  - Full desktop setups (Hyprland, Niri, GNOME)

- **`programs/`** - GUI and TUI applications
- **`roles/`** - User role definitions
- **`security/`** - User-level security
- **`services/`** - User services
- **`styles/`** - User styling preferences
- **`user/`** - User account settings

## 4. Host Configurations

Each host has a dedicated directory in `systems/<architecture>/<hostname>/`:

### tars (x86_64-linux)
- **Hardware**: Tuxedo InfinityBook Pro14 (AMD Ryzen)
- **Role**: Desktop/laptop
- **Features**: Hyprland desktop, gaming support, development environment

### case (x86_64-linux)
- **Hardware**: Lenovo ThinkPad T14 Gen1 (AMD)
- **Role**: Desktop/laptop
- **Features**: Niri desktop, portable workstation

### ava (x86_64-linux)
- **Hardware**: Lenovo ThinkPad X250
- **Role**: Older laptop
- **Features**: Lightweight configuration

### hal (x86_64-linux)
- **Hardware**: Homelab server
- **Role**: Server
- **Services**:
  - Traefik (reverse proxy)
  - Home Assistant (home automation)
  - Jellyfin (media streaming)
  - Navidrome (music streaming)
  - PostgreSQL (database)
  - TeslaMate (Tesla data logging)
  - Authentik (SSO)
  - Monitoring stack (Prometheus, Grafana)
  - Forgejo (Git hosting)
  - And many more services...

### jarvis (aarch64-linux)
- **Hardware**: ARM64 server
- **Role**: ARM server
- **Features**: ARM-optimized server configuration

## 5. Custom Packages

Custom packages are defined in `packages/` and automatically exposed by Snowfall Lib as `pkgs.flocke.<package-name>`.

### Available Custom Packages

- **`matter-server-js`** - Matter.js-based Matter controller server
  - Provides WebSocket API compatible with Home Assistant's Matter integration
  - Alternative to python-matter-server
  - TypeScript implementation using matter.js library

- **`n8n`** - Custom build of N8N automation platform
  - Workflow automation tool
  - Self-hosted alternative to Zapier

- **`octodns`** - DNS management tool
  - Declarative DNS zone management
  - Multi-provider support

- **`dim`** - Custom utility package

- **`premiumizarr-nova`** - Custom utility for media management

- **`wallpapers`** - Collection of custom wallpapers

- **`zonefiles`** - DNS zone files for domain management

## 6. Common Patterns

> **⚠️ IMPORTANT - Git Tracking Requirement**
>
> Before building or deploying any new modules, packages, or configuration files, you **MUST** add them to git (at minimum, stage them with `git add`). Nix flakes only recognize files that are tracked by git. If you create a new directory or file and try to build without adding it to git first, Nix/Snowfall will not see it and your build will fail or the module will not be recognized.
>
> ```bash
> # After creating a new module/package/file:
> git add modules/nixos/services/my-new-service/
> # Now you can build/deploy
> just check
> just apply
> ```

### Adding a New NixOS Module

1. Create a new file in the appropriate subdirectory under `modules/nixos/`
2. **Add the new file/directory to git**: `git add modules/nixos/path/to/module/`
3. Follow the standard module pattern (see template below)
4. The module will be automatically discovered by Snowfall Lib

**Module Template:**
```nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.example;
in
{
  options.services.flocke.example = {
    enable = mkEnableOption "Example service";

    option = mkOption {
      type = types.str;
      default = "default-value";
      description = "Description of this option";
    };
  };

  config = mkIf cfg.enable {
    # Your configuration here
    systemd.services.example = {
      description = "Example service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.example}/bin/example";
      };
    };
  };
}
```

### Adding a New Home Manager Module

1. Create a new file in the appropriate subdirectory under `modules/home/`
2. **Add the new file/directory to git**: `git add modules/home/path/to/module/`
3. Use the `programs.flocke.*` namespace
4. Follow the enable pattern

**Home Manager Module Template:**
```nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.flocke.example;
in
{
  options.programs.flocke.example = {
    enable = mkEnableOption "Example program";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.example ];

    programs.example = {
      enable = true;
      # Additional configuration
    };
  };
}
```

### Adding a New Host

1. Create a directory: `systems/<architecture>/<hostname>/`
2. Create `default.nix` with the system configuration
3. **Add the new directory to git**: `git add systems/<architecture>/<hostname>/`

**System Configuration Example:**
```nix
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ];

  # Enable desired modules
  services.flocke.example.enable = true;

  # Host-specific configuration
  networking.hostName = "hostname";

  system.stateVersion = "24.11";
}
```

4. If needed, add the host to flake inputs

### Adding a Custom Package

1. Create a directory: `packages/<package-name>/`
2. Create `default.nix` with the package definition
3. **Add the new directory to git**: `git add packages/<package-name>/`

```nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation {
  pname = "example";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "example";
    repo = "example";
    rev = "v1.0.0";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp example $out/bin/
  '';

  meta = {
    description = "Example package";
    homepage = "https://example.com";
    license = lib.licenses.mit;
  };
}
```

4. The package will be automatically available as `pkgs.flocke.<package-name>`

### Module Naming Conventions

- **NixOS modules**: Use `services.flocke.*` namespace for services
- **Home Manager modules**: Use `programs.flocke.*` namespace for programs
- **All modules**: Must have an `enable` option (opt-in by default)
- **File structure**: Match the module path (e.g., `services/example/` → `services.flocke.example`)

## 7. Key Files

### `flake.nix`
Main flake definition file that uses Snowfall Lib to automatically discover and organize modules, packages, and systems. Defines all external dependencies (inputs) and exports configurations (outputs).

### `flake.lock`
Lock file that pins all dependency versions for reproducible builds. Updated with `nix flake update`.

### `justfile`
Task runner recipes for common operations. Contains shortcuts for deployment, building, and maintenance tasks.

### `README.md`
Project documentation with installation instructions, feature overview, and attribution to original projects.

### `.envrc`
Direnv configuration that automatically loads the Nix development shell when entering the project directory.

## 8. Common Commands

The project uses [just](https://github.com/casey/just) as a task runner. Common recipes:

```bash
# List all available commands
just help

# Run Nix flake checks (linting, formatting, evaluation)
just check

# Deploy to a remote host
just deploy <hostname>
# Examples:
just deploy hal      # Deploy to hal server
just deploy ava      # Deploy to ava laptop

# Apply configuration to the local host
just apply

# Build installation ISO
just iso             # Build minimal ISO
just iso graphical   # Build graphical ISO

# Manage DNS with OctoDNS
just dns             # Update DNS records
```

### Other Common Operations

```bash
# Update flake dependencies
nix flake update

# Build a specific host configuration (without applying)
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Build a custom package
nix build .#<package-name>

# Enter development shell
nix develop

# Format Nix files
nix fmt

# Check flake evaluation
nix flake check
```

## 9. Secrets Management

The project uses **sops-nix** for encrypted secrets management:

### How it Works
- Secrets are encrypted using age keys derived from SSH host keys
- Each host can only decrypt its own secrets
- Secrets are stored in encrypted YAML files (if `secrets/` directory exists)
- Decryption happens at system activation time

### Usage Pattern
```nix
{
  sops.secrets.example = {
    sopsFile = ./secrets.yaml;
    owner = "user";
  };

  # Reference the secret in configuration
  services.example.passwordFile = config.sops.secrets.example.path;
}
```

### Key Management
- Age keys are automatically derived from SSH host keys
- Private key: `/etc/ssh/ssh_host_ed25519_key`
- Public key: Used for encryption in `.sops.yaml`

## 10. Important Conventions

### Namespacing
- **NixOS services**: `services.flocke.*`
- **Home Manager programs**: `programs.flocke.*`
- **Custom packages**: `pkgs.flocke.*` (auto-generated by Snowfall Lib)

### Module Design
- All modules are **opt-in** via `enable` options
- Never enable modules by default
- Use sensible defaults for options
- Provide clear descriptions for all options
- Follow existing module structure for consistency

### Theming
- Use **Catppuccin** color scheme (Mocha variant typically)
- Apply theming via **Stylix** when possible
- Maintain consistent styling across all applications

### Code Style
- Format all Nix code with `nixpkgs-fmt` (via `nix fmt`)
- Use 2-space indentation
- Place `imports` at the top of each module
- Order options alphabetically when possible
- Add comments for complex logic

### Version Management
- Pin `system.stateVersion` and `home.stateVersion`
- Never change state versions on existing systems
- Only update state version on fresh installs

## 11. Dependencies

### Core Flake Inputs

The project depends on these external flakes (defined in `flake.nix`):

**Essential:**
- **`nixpkgs`** - Main package repository (unstable channel)
- **`home-manager`** - User environment management
- **`snowfall-lib`** - Flake framework providing automatic discovery

**Deployment:**
- **`deploy-rs`** - Remote deployment tool
- **`disko`** - Declarative disk partitioning

**Hardware & Boot:**
- **`nixos-hardware`** - Hardware-specific configurations
- **`lanzaboote`** - Secure boot support

**Theming:**
- **`catppuccin`** - Catppuccin theme for various applications
- **`stylix`** - System-wide color scheme management

**Security:**
- **`sops-nix`** - Secrets management
- **`nix-secrets`** - Private secrets repository (not public)

**Utilities:**
- **`impermanence`** - Opt-in state persistence
- **`nix-colors`** - Color scheme library

### Package Dependencies

Custom packages may have additional dependencies defined in their respective `default.nix` files. Check `packages/<name>/default.nix` for specific package dependencies.

## 12. Development Workflow

### Initial Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/daniel-pieper/nix-flocke.git
   cd nix-flocke
   ```

2. The development shell will load automatically via direnv, or manually:
   ```bash
   nix develop
   ```

### Making Changes

1. **Edit modules** in `modules/nixos/` or `modules/home/`
2. **Test changes** locally:
   ```bash
   just check    # Verify Nix evaluation
   just apply    # Apply to local machine (if applicable)
   ```

3. **Deploy to servers**:
   ```bash
   just deploy <hostname>
   ```

### Testing Configurations

**Local testing** (on the development machine):
```bash
# Check flake evaluation and formatting
nix flake check

# Build without applying
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Apply locally
just apply
# or
sudo nixos-rebuild switch --flake .
```

**Remote testing** (on servers):
```bash
# Deploy to a server
just deploy hal

# Deploy to multiple servers
just deploy hal && just deploy jarvis
```

### Development Best Practices

1. **Test before deploying** - Always run `just check` before deploying
2. **Small commits** - Make incremental changes and commit frequently
3. **Clear commit messages** - Describe what and why
4. **Review changes** - Use `git diff` before committing
5. **Keep secrets safe** - Never commit unencrypted secrets

### Updating Dependencies

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Check what changed
git diff flake.lock
```

### Troubleshooting

**Build fails:**
- Check `nix flake check` output
- Review error messages carefully
- Verify all imports are correct
- Check for syntax errors with `nix fmt`

**Deployment fails:**
- Verify SSH access to target host
- Check network connectivity
- Review deploy-rs output for specific errors
- Ensure target host has enough disk space

**Module not found:**
- Verify file is in correct directory under `modules/`
- Check filename matches expected pattern
- Ensure Snowfall Lib can discover it (check path structure)

## 13. Additional Resources

### Related Projects
- Based on [nixicle](https://github.com/person/nixicle)
- Inspired by [hlissner/dotfiles](https://github.com/hlissner/dotfiles)
- Uses patterns from [Mic92/dotfiles](https://github.com/Mic92/dotfiles)

### External Documentation
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Snowfall Lib Documentation](https://snowfall.org/guides/lib/)
- [Stylix Documentation](https://stylix.danth.me/)

### Community Resources
- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Wiki](https://nixos.wiki/)
- [Nix Package Search](https://search.nixos.org/)

---

**Last Updated**: 2025-12-27
**Maintainer**: Daniel Pieper
**Repository**: https://github.com/daniel-pieper/nix-flocke
