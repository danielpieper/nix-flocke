{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
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
