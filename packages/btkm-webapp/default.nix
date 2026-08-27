{
  lib,
  runCommandLocal,
  inputs,
}:

# https://forgejo.naseschief.de/daniel/btkm
# Web app for the btkm USB-to-BLE HID switch. Static files only: it drives the
# Pi over Web Bluetooth straight from the browser, so there is no server
# component. Web Bluetooth demands a secure context, which is why this is
# served over HTTPS rather than opened from disk.
# Bump with `nix flake update btkm`.
runCommandLocal "btkm-webapp" { } ''
  install -Dm444 ${inputs.btkm}/webapp/spike/index.html $out/spike/index.html
''
// {
  meta = {
    description = "Static web app for the btkm BLE HID switch";
    homepage = "https://forgejo.naseschief.de/daniel/btkm";
    maintainers = with lib.maintainers; [ danielpieper ];
    platforms = lib.platforms.all;
  };
}
