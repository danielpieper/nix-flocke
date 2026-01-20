{
  inputs,
  lib,
  buildGoModule,
  buildNpmPackage,
}:

let
  frontend = buildNpmPackage {
    pname = "premiumizearr-nova-frontend";
    version = "1.4.5";

    src = inputs.premiumizearr-nova;
    sourceRoot = "source/web";
    npmDepsHash = "sha256-b4hdjg1MwC7JP2WH2MdRYGwgMf3tOOpuyvjD5iPlhrY=";
    postInstall = ''
      rm -rf $out/lib
      cp -r dist/* $out/
    '';
  };
in

buildGoModule {
  pname = "premiumizarr-nova";
  version = "1.4.5";

  src = inputs.premiumizearr-nova;
  vendorHash = "sha256-CsD+Xv1k6GImfdzhRNE9/75XQ5fec2uNJJGLBaUqnBo=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];
  postInstall = ''
    mkdir -p $out/static
    cp -r ${frontend}/* $out/static/
  '';

  meta = with lib; {
    description = "DownloadManger for *Arr clients (Sonarr, Radarr) utilizing Premiumize Usnet Blackhole";
    homepage = "https://github.com/ensingerphilipp/Premiumizearr-Nova";
    platforms = platforms.linux;
  };
}
