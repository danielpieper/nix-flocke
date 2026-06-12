{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.roles.desktop;
in
{
  options.roles.desktop = {
    enable = mkEnableOption "Enable desktop configuration";
  };

  config = mkIf cfg.enable {
    boot = {
      binfmt.emulatedSystems = [ "aarch64-linux" ];
      kernel.sysctl = {
        # TCP BBR for better throughput and lower latency
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
        # Higher swappiness to prefer zram (compressed in-memory) over keeping cold pages
        "vm.swappiness" = 180;
        # Lower dirty ratios to avoid btrfs CoW write stalls
        "vm.dirty_background_ratio" = 5;
        "vm.dirty_ratio" = 10;
      };
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };

    roles = {
      common.enable = true;

      desktop.addons = {
        nautilus.enable = true;
        _1password.enable = true;
      };
    };

    hardware = {
      audio.enable = true;
      bluetoothctl.enable = true;
      logitechMouse.enable = true;
      dygmaKeyboard.enable = true;
    };

    programs.regreet.enable = true;
    # regreet 0.4.0 added animated/video login backgrounds via GTK's GtkMediaFile,
    # which needs GStreamer's playbin3 element. The upstream wrapper wires no
    # GST_PLUGIN path, so the greeter dies with "playbin3 element not found".
    # Re-wrap regreet to expose gst-plugins-{base,good} (base provides playbin3;
    # good provides webm/vp8/vp9 demux+decode for video backgrounds).
    programs.regreet.package = pkgs.symlinkJoin {
      name = "regreet-gst";
      inherit (pkgs.regreet) version;
      paths = [ pkgs.regreet ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/regreet \
          --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${
            lib.makeSearchPath "lib/gstreamer-1.0" (
              with pkgs.gst_all_1;
              [
                gstreamer
                gst-plugins-base
                gst-plugins-good
              ]
            )
          }"
      '';
      meta = pkgs.regreet.meta // {
        mainProgram = "regreet";
      };
    };

    services = {
      irqbalance.enable = true;
      dbus.implementation = "broker";
      flocke = {
        # systemd-resolved[810]: mDNS-IPv4: There appears to be another mDNS responder running, or previously systemd-resolved crashed with some outstanding transfers.
        # avahi.enable = true;
        restic.enable = true;
        virtualisation.podman.enable = true;
        tailscale.enable = true;
      };
      upower.enable = true;
      logind.settings.Login.HandlePowerKey = "suspend";
    };

    system = {
      boot.plymouth = true;
    };

    # Deprioritize heavy background services to keep desktop responsive
    systemd.services = lib.mkMerge [
      (lib.mkIf config.services.ollama.enable {
        ollama.serviceConfig = {
          CPUWeight = 50;
          IOWeight = 50;
          CPUSchedulingPolicy = "batch";
        };
      })
      (lib.mkIf config.services.llama-cpp.enable {
        llama-cpp.serviceConfig = {
          CPUWeight = 50;
          IOWeight = 50;
          CPUSchedulingPolicy = "batch";
        };
      })
    ];

    cli.programs = {
      nh.enable = true;
      nix-ld.enable = true;
    };

    user = {
      name = "daniel";
    };
  };
}
