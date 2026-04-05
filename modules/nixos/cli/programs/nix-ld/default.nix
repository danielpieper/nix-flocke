{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.programs.nix-ld;
in
{
  options.cli.programs.nix-ld = with types; {
    enable = mkBoolOpt false "Whether or not to enable nix-ld.";
  };

  config = mkIf cfg.enable {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      libx11
      libxcursor
      libxrandr
      libxi
      libxext
      libxfixes
      libxcb
      wayland
      libxkbcommon
      vulkan-loader
      libGL
      SDL2
      gtk3
      glib
      sqlite
      stdenv.cc.cc.lib
      openal
      alsa-lib
      udev
      fontconfig
      freetype
      zlib
      libdrm
      libcap
      dbus
    ];
  };
}
