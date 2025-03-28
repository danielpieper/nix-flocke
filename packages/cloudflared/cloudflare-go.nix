{ stdenv
, fetchFromGitHub
, go_1_22
,
}:

stdenv.mkDerivation {
  pname = "cloudflare-go";
  version = "latest"; # Falls eine spezifische Version benötigt wird, setze sie hier

  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "go";
    rev = "af19da5605ca11f85776ef7af3384a02a315a52b"; # Falls du einen bestimmten Commit oder Tag brauchst, passe das an
    sha256 = "sha256-6VT9CxlHkja+mdO1DeFoOTq7gjb3T5jcf2uf9TB/CkU="; # Führe `nix-prefetch-url` oder `nix-prefetch-git` aus, um den Wert zu erhalten
  };

  nativeBuildInputs = [ go_1_22 ];

  buildPhase = ''
    export GOROOT_BOOTSTRAP=${go_1_22}/share/go
    export GOCACHE=$TMPDIR/go-cache
    mkdir -p $GOCACHE
    pushd src
    bash make.bash
    popd
  '';

  installPhase = ''
    mkdir -p $out/share/go $out/bin
    cp -a bin pkg src lib misc api doc go.env $out/share/go
    ln -s $out/share/go/bin/* $out/bin
  '';
}
