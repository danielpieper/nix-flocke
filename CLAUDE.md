# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**nix-flocke** is a personal NixOS configuration repository managing multiple machines using Nix Flakes and Snowfall Lib. It configures both personal workstations (tars, case, ava) and home lab servers (hal, jarvis).

Key technologies: Nix Flakes, Snowfall Lib, Home Manager, sops-nix, Impermanence, Stylix/Catppuccin theming.

## Common Commands

```bash
just check              # Run nix flake check (linting, formatting, evaluation)
just apply              # Apply configuration to local host (uses nh os switch)
just deploy <hostname>  # Deploy to remote host (hal, jarvis, ava)
just iso [graphical]    # Build installation ISO
nix fmt                 # Format Nix files
nix flake update        # Update all dependencies
```

## Architecture

### Snowfall Lib Structure

Snowfall Lib auto-discovers modules, packages, and systems based on directory structure:

- `modules/nixos/` → NixOS modules (system-level)
- `modules/home/` → Home Manager modules (user-level)
- `systems/<arch>/<hostname>/` → Host configurations
- `homes/<arch>/<user>@<host>/` → Per-user home configurations
- `packages/<name>/` → Custom packages (exposed as `pkgs.flocke.<name>`)
- `overlays/` → Package overlays

### Module Namespacing

- **NixOS services**: `services.flocke.*`
- **Home Manager programs**: `programs.flocke.*`
- **Custom packages**: `pkgs.flocke.*`

### Hosts

| Host | Arch | Role | Notes |
|------|------|------|-------|
| tars | x86_64 | Desktop | Tuxedo laptop, Hyprland/Niri |
| case | x86_64 | Desktop | ThinkPad T14, Niri |
| ava | x86_64 | Desktop | ThinkPad X250 |
| hal | x86_64 | Server | Main homelab (Traefik, Home Assistant, Jellyfin, etc.) |
| jarvis | aarch64 | Server | ARM server |

## Critical: Git Tracking Requirement

**New files MUST be git-tracked before building.** Nix flakes only see files tracked by git:

```bash
git add modules/nixos/services/my-new-service/
just check  # Now Snowfall will discover the module
```

## Module Patterns

### NixOS Module Template

```nix
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.flocke.example;
in
{
  options.services.flocke.example = {
    enable = mkEnableOption "Example service";
  };

  config = mkIf cfg.enable {
    # Configuration here
  };
}
```

### Home Manager Module Template

```nix
{ config, lib, pkgs, ... }:
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
  };
}
```

## Secrets Management (sops-nix)

Secrets are encrypted with age keys derived from SSH host keys:

```nix
{
  sops.secrets.example = {
    sopsFile = ./secrets.yaml;
    owner = "user";
  };

  services.example.passwordFile = config.sops.secrets.example.path;
}
```

## Conventions

- All modules are opt-in via `enable` options
- Format with `nix fmt` (nixpkgs-fmt), 2-space indentation
- Use Catppuccin Mocha theme via Stylix
- Never change `stateVersion` on existing systems
