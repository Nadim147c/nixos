{
  fetchurl,
  jre,
  lib,
  libGL,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  stdenv,
  unzip,
  imagemagick,
  wrapGAppsHook3,
}:

let
  inherit (lib) singleton;
  inherit (lib.licenses) gpl3Only;
  inherit (lib.sourceTypes) binaryBytecode;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "morphe-desktop";
  version = "1.18.0";

  src = fetchurl {
    url = "https://github.com/MorpheApp/${finalAttrs.pname}/releases/download/v${finalAttrs.version}/morphe-desktop-${finalAttrs.version}-all.jar";
    hash = "sha256-NuINehj2VftYKa5Qqt1hIX4iCFNsB0HfX3eZMA91j1Y=";
  };

  strictDeps = true;

  desktopItems = singleton (makeDesktopItem {
    name = "morphe";
    desktopName = "Morphe";
    genericName = "Android software patcher";
    exec = "morphe-desktop";
    icon = "morphe-desktop";
    categories = [ "Development" ];
  });

  nativeBuildInputs = [
    unzip
    wrapGAppsHook3
    makeWrapper
    imagemagick
    copyDesktopItems
  ];

  buildInputs = [
    jre
    libGL
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p \
      "$out/bin" \
      "$out/share/doc/morphe-desktop" \
      "$out/share/morphe-desktop"

    install -Dm644 "$src" "$out/share/morphe-desktop/morphe-desktop.jar"

    makeWrapper ${jre}/bin/java "$out/bin/morphe-desktop" \
      --add-flags "-jar $out/share/morphe-desktop/morphe-desktop.jar" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL ]}" \

    unzip -p "$src" NOTICE > "$out/share/doc/morphe-desktop/NOTICE"
    unzip -p "$src" morphe_logo.png > logo.png

    for i in 16 24 48 64 96 128 256 512; do
      mkdir -p "$out/share/icons/hicolor/''${i}x''${i}/apps"

      magick logo.png \
        -background none \
        -resize "''${i}x''${i}" \
        "$out/share/icons/hicolor/''${i}x''${i}/apps/morphe-desktop.png"
    done

    runHook postInstall
  '';

  meta = {
    description = "An application that patches Android applications";
    homepage = "https://github.com/MorpheApp/morphe-desktop";
    license = gpl3Only;
    sourceProvenance = singleton binaryBytecode;
    maintainers = singleton lib.maintainers.Nadim147c;
    mainProgram = "morphe-desktop";
  };
})
