{
  lib,
  buildNpmPackage,
  inputs,
}:

# https://forgejo.naseschief.de/daniel/btkm
# Web app for the btkm USB-to-BLE HID switch. A static Svelte bundle with no
# backend: it drives the Pi over Web Bluetooth straight from the browser, which
# is why it needs a secure context and can be served from a tailnet-only origin.
# Bump with `nix flake update btkm`; refresh npmDepsHash whenever
# webapp/package-lock.json changes.
buildNpmPackage {
  pname = "btkm-webapp";
  version = "0.1.0";

  src = "${inputs.btkm}/webapp";

  npmDepsHash = "sha256-ErLz14GVzP20Ii27OnE0eBvIvV42apClqBM+wHIG1Fc=";

  # The default installPhase runs `npm pack`, which is meaningless for a static
  # site; the Vite bundle in dist/ is the whole artifact.
  installPhase = ''
    runHook preInstall
    cp -r dist $out
    runHook postInstall
  '';

  meta = {
    description = "Static web app for the btkm BLE HID switch";
    homepage = "https://forgejo.naseschief.de/daniel/btkm";
    maintainers = with lib.maintainers; [ danielpieper ];
    platforms = lib.platforms.all;
  };
}
