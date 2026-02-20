_: _: prev: {
  nautilus = prev.nautilus.overrideAttrs (old: {
    buildInputs =
      old.buildInputs
      ++ (with prev.gst_all_1; [
        gst-plugins-good
        gst-plugins-bad
        gst-plugins-ugly
        gst-libav
      ]);
  });
}
