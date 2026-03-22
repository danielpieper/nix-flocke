_: _: prev: {
  ollama-rocm = prev.ollama-rocm.overrideAttrs (_: {
    version = "0.18.2";
    src = prev.fetchFromGitHub {
      owner = "ollama";
      repo = "ollama";
      tag = "v0.18.2";
      hash = "sha256-BDCYczTZO6LKwD8+LY625pZwvJVMYUE0VwVG5pVYfGk=";
    };
  });
}
