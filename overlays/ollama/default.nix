_: _: prev: {
  ollama-rocm = prev.ollama-rocm.overrideAttrs (_: {
    version = "0.17.8-rc4";
    src = prev.fetchFromGitHub {
      owner = "ollama";
      repo = "ollama";
      tag = "v0.17.8-rc4";
      hash = "sha256-yjpK6ujmt4UO2doXsBnNPaNO5Dn6idTSyf37/SruXn8=";
    };
  });
}
