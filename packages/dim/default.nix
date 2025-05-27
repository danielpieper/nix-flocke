{
  lib,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  pkg-config,
  openssl,
  dbus,
  libxkbcommon,
  wayland,
  wayland-protocols,
}:

# https://github.com/marcelohdez/dim/
# https://github.com/marcelohdez/dim/tree/master/example
rustPlatform.buildRustPackage {
  pname = "dim";
  version = "0-unstable-2023-10-15";

  src = fetchFromGitHub {
    owner = "marcelohdez";
    repo = "dim";
    rev = "c516aaa0482e9aec2cce1bdb42c8186c87b37379";
    hash = "sha256-n1CV4Gge7ugjaMIv3MHbh6Yg6ofvmjYi5046CnI8BPE=";
  };

  cargoHash = "sha256-iQT5RwL7me1vusvSyBxqgRK+Dpk+FDn7F6w+VtWCHZc=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    dbus
    libxkbcommon
    wayland
    wayland-protocols
  ];

  # Set environment variables if needed for linking
  OPENSSL_NO_VENDOR = 1;

  # Run tests unless they require hardware access or are flaky
  doCheck = true;

  meta = with lib; {
    description = "A fast and simple brightness control utility";
    longDescription = ''
      dim is a command-line utility for controlling screen brightness
      on Linux systems. It provides a simple interface for adjusting
      brightness levels quickly and efficiently.
    '';
    homepage = "https://github.com/marcelohdez/dim";
    changelog = "https://github.com/marcelohdez/dim/releases";
    license = licenses.mit;
    maintainers = with maintainers; [
      danielpieper
    ];
    mainProgram = "dim";
    platforms = platforms.linux;
    broken = stdenv.isDarwin;
  };
}
