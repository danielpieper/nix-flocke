{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  bun,
  esbuild,
  makeWrapper,
}:

# https://gitlab.futo.org/futo-notes/futo-notes-server
# E2EE sync server for FUTO Notes. Upstream only ships a Docker image, so this
# reproduces its build: bundle src/ into a single ESM file, keep `pg` external,
# and run it under Bun (src/server.ts calls Bun.serve, so node is not enough).
#
# Upstream has no package-lock.json — only bun.lock — so ./package-lock.json is
# generated with `npm install --package-lock-only` and vendored here. Regenerate
# it (and both hashes) when bumping the version.
buildNpmPackage (finalAttrs: {
  pname = "futo-notes-server";
  version = "0.6.0";

  src = fetchFromGitLab {
    domain = "gitlab.futo.org";
    owner = "futo-notes";
    repo = "futo-notes-server";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bSfktqOJ1QmH8WsVha6ksh0e6mV9ADS9o0sIvQXX864=";
  };

  # Writable, because `npm prune` in installPhase rewrites the lockfile.
  postPatch = ''
    install -m 644 ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-6EMmbL3FIQ1bn0bejJsJZJCKAUdzrdlt1PtEz39DKVc=";

  nativeBuildInputs = [
    esbuild
    makeWrapper
  ];

  # build.mjs imports esbuild's JS API, which the nixpkgs esbuild (a Go binary)
  # does not provide. The CLI invocation below is the same build, flag for flag.
  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild

    esbuild src/index.ts \
      --bundle \
      --platform=node \
      --target=node24 \
      --format=esm \
      --outfile=dist/index.js \
      --external:pg \
      --external:pg-native \
      "--banner:js=import { createRequire as __createRequire } from 'node:module';
    const require = __createRequire(import.meta.url);"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    npm prune --omit=dev
    mkdir -p $out/lib/futo-notes-server
    cp -r dist node_modules package.json $out/lib/futo-notes-server/

    makeWrapper ${lib.getExe bun} $out/bin/futo-notes-server \
      --add-flags "$out/lib/futo-notes-server/dist/index.js"

    runHook postInstall
  '';

  meta = {
    description = "Self-hosted end-to-end encrypted sync server for FUTO Notes";
    homepage = "https://gitlab.futo.org/futo-notes/futo-notes-server";
    # FUTO Source First License 1.1 — source available, non-commercial use only.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ danielpieper ];
    mainProgram = "futo-notes-server";
    platforms = lib.platforms.linux;
  };
})
