{
  pkgs,
  ...
}:
# see https://gist.github.com/Mihitoko/bd76340e56e78ec972c8a1365abb0d55
pkgs.stdenv.mkDerivation {
  pname = "geforcenow";
  version = "2.0.0";

  src = pkgs.fetchurl {
    url = "https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo";
    sha256 = "sha256-sc6Th5MxoVAoEke1I55/irBKRpKaeGN/lSjVg1B3nbw=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications

    # Create wrapper script that ensures Wayland support
    cat > $out/bin/geforcenow << 'EOF'
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
    EOF

    chmod +x $out/bin/geforcenow

    # Create desktop entry
    cat > $out/share/applications/geforcenow-hd.desktop << 'EOF'
    [Desktop Entry]
    Type=Application
    Name=GeForce NOW HD
    Comment=NVIDIA GeForce NOW Cloud Gaming
    Exec=gamescope --force-grab-cursor --adaptive-sync -f -w 1920 -h 1200 -- geforcenow
    Icon=com.nvidia.geforcenow
    Categories=Game;
    Terminal=false
    StartupNotify=true
    EOF

    # Create desktop entry
    cat > $out/share/applications/geforcenow-wqhd.desktop << 'EOF'
    [Desktop Entry]
    Type=Application
    Name=GeForce NOW WQHD
    Comment=NVIDIA GeForce NOW Cloud Gaming
    Exec=gamescope --force-grab-cursor --adaptive-sync -f -w 2560 -h 1440 -- geforcenow
    Icon=com.nvidia.geforcenow
    Categories=Game;
    Terminal=false
    StartupNotify=true
    EOF

    # Create helper script for troubleshooting
    cat > $out/bin/geforcenow-logs << 'EOF'
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
    EOF

    chmod +x $out/bin/geforcenow-logs
  '';

  meta = with pkgs.lib; {
    description = "NVIDIA GeForce NOW cloud gaming service (Flatpak wrapper with Wayland support)";
    longDescription = ''
      GeForce NOW cloud gaming service from NVIDIA.

      This package installs GeForce NOW as a Flatpak application with Wayland support.

      By default, the app will use native Wayland. If you experience issues:
      - Run 'geforcenow-logs' to view application logs
      - Run 'geforcenow-force-xwayland' to force XWayland mode

      Known issues:
      - Network test may fail even with working connection (workaround: set Custom streaming quality in settings)
      - Login may require manual OAuth URL from logs
    '';
    homepage = "https://www.nvidia.com/en-us/geforce-now/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
