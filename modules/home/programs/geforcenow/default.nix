{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.flocke.geforcenow;
  geforceNowBin = pkgs.writeScriptBin "geforcenow" ''
    #!/usr/bin/env bash

    # Check if GeForce NOW is installed
    if ! flatpak list --user | grep -q com.nvidia.geforcenow; then
      echo "GeForce NOW is not installed. Installing now..."

      # Add flathub remote
      flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

      # Install runtime
      flatpak install --user --noninteractive flathub org.freedesktop.Sdk//24.08

      # Add GeForce NOW remote
      flatpak remote-add --user --if-not-exists GeForceNOW https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo

      # Install GeForce NOW
      flatpak install --user --noninteractive GeForceNOW com.nvidia.geforcenow
    fi

    flatpak override --user --nosocket=wayland com.nvidia.geforcenow
    flatpak run --user --nofilesystem=host-etc --command=bash com.nvidia.geforcenow -c '
        # Exit immediately if a command exits with a non-zero status.
        set -e

        # Create the directory that holds the os-release and SSL certs
        mkdir -p /run/host/etc/ssl

        # Create the SteamOS os-release file
        cat > /run/host/etc/os-release << 'GFNEOF'
    NAME="SteamOS"
    PRETTY_NAME="SteamOS"
    VERSION_CODENAME=holo
    ID=steamos
    ID_LIKE=arch
    ANSI_COLOR="1;35"
    HOME_URL="https://www.steampowered.com/"
    DOCUMENTATION_URL="https://support.steampowered.com/"
    SUPPORT_URL="https://support.steampowered.com/"
    BUG_REPORT_URL="https://support.steampowered.com/"
    LOGO=steamos
    VARIANT_ID=steamdeck
    BUILD_ID=20250522.1
    VERSION_ID=3.7.8
    GFNEOF

        # Recursively copy the host systems SSL certificates into the sandbox
        cp -r /etc/ssl /run/host/etc/

        # Launch GeForce NOW
        echo "Launching GeForce NOW..."
        /app/bin/GeForceNOW
    '
  '';
  geforceNowLogs = pkgs.writeScriptBin "geforcenow-logs" ''
    #!/usr/bin/env bash

    echo "=== GeForce NOW Logs ==="
    echo ""
    echo "--- Geronimo Log ---"
    cat ~/.var/app/com.nvidia.geforcenow/.local/state/NVIDIA/GeForceNOW/geronimo.log 2>/dev/null || echo "Log not found"
    echo ""
    echo "--- Main Log ---"
    cat ~/.var/app/com.nvidia.geforcenow/.local/state/NVIDIA/GeForceNOW/GeForceNOW.log 2>/dev/null || echo "Log not found"
    echo ""
    echo "--- OAuth URL (if login fails) ---"
    tac ~/.var/app/com.nvidia.geforcenow/.local/state/NVIDIA/GeForceNOW/console.log 2>/dev/null | grep starfleet/o-auth | head -n 1 || echo "No OAuth URL found"
  '';
in
{
  options.programs.flocke.geforcenow = {
    enable = mkEnableOption "Enable NVIDIA GeForce NOW cloud gaming service";
  };

  config = mkIf cfg.enable {
    home.packages = [
      geforceNowBin
      geforceNowLogs
    ];

    xdg.desktopEntries = {
      "com.nvidia.geforcenow-hd" = {
        type = "Application";
        name = "GeForce NOW HD";
        exec = "${pkgs.gamescope}/bin/gamescope --force-grab-cursor --adaptive-sync -f -w 1920 -h 1200 -- ${geforceNowBin}/bin/geforcenow";
        comment = "NVIDIA GeForce NOW Cloud Gaming";
        icon = "com.nvidia.geforcenow";
        categories = [ "Game" ];
        terminal = false;
        startupNotify = true;
      };
      "com.nvidia.geforcenow-wqhd" = {
        type = "Application";
        name = "GeForce NOW WQHD";
        exec = "${pkgs.gamescope}/bin/gamescope --force-grab-cursor --adaptive-sync -f -w 2560 -h 1440 -- ${geforceNowBin}/bin/geforcenow";
        comment = "NVIDIA GeForce NOW Cloud Gaming";
        icon = "com.nvidia.geforcenow";
        categories = [ "Game" ];
        terminal = false;
        startupNotify = true;
      };
    };
  };
}
