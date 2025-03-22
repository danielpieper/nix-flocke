{
  pkgs,
  lib,
  buildGoModule,
  buildNpmPackage,
}:

let
  frontend = buildNpmPackage {
    pname = "premiumizearr-nova-frontend";
    version = "1.4.0";

    src = pkgs.fetchFromGitHub {
      owner = "ensingerphilipp";
      repo = "Premiumizearr-Nova";
      rev = "main";
      sha256 = "sha256-fG01lQi2rT0tCdaxXRxHUBSOrjrLUzy7z3IR4aMFdFQ=";
    };
    sourceRoot = "source/web";
    npmDepsHash = "sha256-chl4TT4/C08QQVmm3qf+ktWKTI8lyhzbnmKr4JBgnQ0=";
    postInstall = ''
      rm -rf $out/lib
      cp -r dist/* $out/
    '';
  };
in

buildGoModule {
  pname = "premiumizarr-nova";
  version = "1.4.0";

  src = pkgs.fetchFromGitHub {
    owner = "ensingerphilipp";
    repo = "Premiumizearr-Nova";
    rev = "main";
    sha256 = "sha256-fG01lQi2rT0tCdaxXRxHUBSOrjrLUzy7z3IR4aMFdFQ=";
  };

  vendorHash = "sha256-AdjjZTVK75hR/ux/9POVWguoUE4Y9iv2jz17P/gKipM=";

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
