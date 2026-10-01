inputs: final: prev: {
  makeIcons =
    name: inputImage:
    final.runCommand "${name}-icons"
      {
        nativeBuildInputs = [ final.imagemagickBig ];
        src = inputImage;
      }
      ''
        sizes=(16 24 32 48 64 96 128 256 512)

        for size in "''${sizes[@]}"; do
          dir="$out/share/icons/hicolor/''${size}x''${size}/apps"
          mkdir -p "$dir"
          magick "$src[0]" -background none -flatten -resize "''${size}x''${size}" "$dir/${name}.png"
        done

        mkdir -p "$out/share/icons/hicolor/scalable/apps"
        magick "$src[0]" "$out/share/icons/hicolor/scalable/apps/${name}.svg" 2>/dev/null || true

        mkdir -p "$out/share/pixmaps"
        magick "$src[0]" -background none -flatten -resize 256x256 "$out/share/pixmaps/${name}.png"
        magick "$src[0]" -resize 256x256 "$out/share/pixmaps/${name}.ico"
      '';
}
