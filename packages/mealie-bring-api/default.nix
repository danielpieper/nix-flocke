{
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  makeWrapper,
}:
let
  pythonEnv = python3.withPackages (ps: [
    ps.flask
    ps.python-dotenv
    ps.aiohttp
    ps.requests
    ps.bring-api
  ]);
in
# https://github.com/felixschndr/mealie-bring-api
# Flask webserver that bridges Mealie recipe actions to a Bring shopping list.
# Upstream has package-mode = false (no entry point); it is run as
# `python -m source.mealie_bring_api` from the repo root.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mealie-bring-api";
  version = "1.2.10";

  src = fetchFromGitHub {
    owner = "felixschndr";
    repo = "mealie-bring-api";
    rev = finalAttrs.version;
    hash = "sha256-iGVVCrnZs9ZR5CkPHOqoFtY5UtPJo73+k8mHbCnp+tY=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/mealie-bring-api
    cp -r source $out/libexec/mealie-bring-api/
    # Ensure `source` is importable as a regular package for `python -m`.
    touch $out/libexec/mealie-bring-api/source/__init__.py

    makeWrapper ${pythonEnv}/bin/python $out/bin/mealie-bring-api \
      --add-flags "-m source.mealie_bring_api" \
      --chdir $out/libexec/mealie-bring-api \
      --prefix PYTHONPATH : $out/libexec/mealie-bring-api

    runHook postInstall
  '';

  meta = {
    description = "Bridge that adds Mealie shopping list ingredients to a Bring list";
    homepage = "https://github.com/felixschndr/mealie-bring-api";
    mainProgram = "mealie-bring-api";
  };
})
