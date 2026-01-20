{
  inputs,
  stdenv,
  ...
}:

inputs.pre-commit-hooks.lib.${stdenv.hostPlatform.system}.run {
  src = ../..;
  hooks = {
    nixfmt.enable = true;
    statix.enable = true;
    deadnix.enable = true;
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-executables-have-shebangs.enable = true;
    check-merge-conflicts.enable = true;
    check-shebang-scripts-are-executable.enable = true;
    check-symlinks.enable = true;
    detect-private-keys.enable = true;
    end-of-file-fixer.enable = true;
    fix-byte-order-marker.enable = true;
    forbid-new-submodules.enable = true;
    mixed-line-endings.enable = true;
    trim-trailing-whitespace.enable = true;
    pre-commit-hook-ensure-sops.enable = true;
  };
}
