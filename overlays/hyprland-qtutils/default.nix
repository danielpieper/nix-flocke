{ inputs, ... }:
final: prev: {
  hyprland-qtutils = inputs.hyprland-qtutils-git.packages.${prev.system}.default;
}
