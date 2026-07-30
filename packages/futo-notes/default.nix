{
  lib,
  appimageTools,
  fetchurl,
}:

# https://gitlab.futo.org/futo-notes/futo-notes
# Tauri desktop client. Building from source needs a vendored pnpm workspace
# plus Cargo.lock; the upstream AppImage already bundles webkit2gtk-4.1, gtk3
# and libsoup-3, so wrapping it is both smaller and far cheaper to bump.
let
  pname = "futo-notes";
  version = "1.6.1";

  src = fetchurl {
    url = "https://gitlab.futo.org/api/v4/projects/488/packages/generic/futo-notes/v${version}/FUTO-Notes-${version}-x86_64.AppImage";
    hash = "sha256-T07VgEwkEFArEXNdvi+3VHJm516C3XBUyVlquUqSCpY=";
  };

  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # WebKit's DMABUF renderer paints a blank window under Wayland compositors on
  # amdgpu, which is exactly tars' setup.
  profile = ''
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
  '';

  extraInstallCommands = ''
    install -Dm444 ${contents}/futo-notes-tauri.png \
      $out/share/icons/hicolor/256x256/apps/futo-notes-tauri.png
    install -Dm444 "${contents}/FUTO Notes.desktop" \
      $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail "Exec=futo-notes-tauri" "Exec=${pname}"
  '';

  meta = {
    description = "Offline-first Markdown notes app with optional E2EE sync";
    homepage = "https://notes.futo.tech/";
    # FUTO Source First License 1.1 — source available, non-commercial use only.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ danielpieper ];
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
