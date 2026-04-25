{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  user = inputs.nix-secrets.user.name;
  # Invoked by Noctalia's darkModeChange hook (which substitutes $1=true|false)
  # via `sudo -n flocke-theme-switch $1`. Runs as root, switches the active
  # specialisation in-place — no rebuild.
  themeSwitch = pkgs.writeShellApplication {
    name = "flocke-theme-switch";
    text = ''
      # /nix/var/nix/profiles/system always points at the base of the current
      # generation, regardless of which specialisation is currently active —
      # /run/current-system follows the active spec and would self-loop.
      base="/nix/var/nix/profiles/system"
      mode="''${1:-}"
      case "$mode" in
        true | dark)   target="$base" ;;
        false | light) target="$base/specialisation/light" ;;
        *)
          echo "usage: flocke-theme-switch true|false|dark|light" >&2
          exit 1
          ;;
      esac
      exec "$target/bin/switch-to-configuration" switch
    '';
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  specialisation.light.configuration = {
    styles.stylix.dark = lib.mkForce false;
    home-manager.users.${user} = {
      styles.stylix.dark = lib.mkForce false;
      programs.noctalia-shell.settings.colorSchemes.darkMode = lib.mkForce false;
      # Stylix sets this to "default" (= "no preference") for light polarity,
      # which xdg-desktop-portal then exports as 0. Apps that "follow system"
      # see no preference and keep their existing (dark) state. Force the
      # explicit "prefer-light" so portal reports 2 and apps actually flip.
      dconf.settings."org/gnome/desktop/interface".color-scheme = lib.mkForce "prefer-light";
    };
  };

  # Use the stable /run/current-system path (not the store path) so sudo's
  # literal-string match succeeds when the script is invoked via PATH.
  # Defaults realpath is off on NixOS, so symlinks are not dereferenced.
  security.sudo.extraRules = [
    {
      users = [ user ];
      commands = [
        {
          command = "/run/current-system/sw/bin/flocke-theme-switch";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  system.impermanence.enable = true;

  roles = {
    desktop = {
      enable = true;
      addons = {
        niri.enable = true;
      };
    };
    gaming.enable = true;
  };

  environment.systemPackages = with pkgs; [
    themeSwitch
    moonlight-qt
    vlc
    obsidian
  ];

  services = {
    flocke = {
      syncthing.enable = true;
      nfs.enable = true;
      restic.excludes = [
        ".local/cache"
        ".local/share/Steam"
        ".local/share/containers"
        ".local/share/Trash"
        ".local/share/flatpak"
        ".terraform/providers"
        "Downloads"
        "node_modules"
        "var/lib/private/ollama"
        "var/cache/llama-cpp"
        "*.img"
        "*.img.zst"
      ];
      ollama = {
        enable = true;
        acceleration = "rocm";
        loadModels = [ ];
      };
      llama-cpp = {
        enable = false;
        acceleration = "vulkan";
        modelsPreset = {
          "qwen3.5-27b-opus" = {
            hf-repo = "Jackrong/Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-GGUF";
            hf-file = "Qwen3.5-27B.Q8_0.gguf";
            alias = "qwen3.5-27b-opus";
            fit = "on";
            jinja = "on";
          };
        };
      };
    };

    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{power/wakeup}="disabled"
    '';

    # Let TUXEDO Control Center handle CPU frequencies
    power-profiles-daemon.enable = false;
  };

  networking.hostName = "tars";

  security.flocke = {
    ausweisapp.enable = true;
  };

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
    resumeDevice = "/dev/disk/by-label/nixos";
  };

  hardware = {
    xone.enable = true;

    # https://fnune.com/hardware/2025/07/20/nixos-on-a-tuxedo-infinitybook-pro-14-gen9-amd/
    tuxedo-control-center.enable = true;
  };

  system.stateVersion = "23.11";
}
