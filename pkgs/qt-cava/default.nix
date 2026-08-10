{
  cava,
  cmake,
  lib,
  makeWrapper,
  ninja,
  qt6,
  stdenv,
  symlinkJoin,
  writeText,
  cavaBarCount ? 16,
  cavaFramerate ? 20,
}:
let
  inherit (qt6.qtbase) qtQmlPrefix;
  inherit (lib) makeLibraryPath cmakeFeature;
  inherit (lib.meta) getExe;
  inherit (lib.platforms) linux;

  cavaConfig = writeText "cava.ini" ''
    [general]
    bars=${toString cavaBarCount}
    framerate=${toString cavaFramerate}

    [output]
    bit_format=8bit
    data_format=binary
    method=raw
    raw_target=/dev/stdout
  '';

  cavaWithConfig = symlinkJoin {
    name = "cava-wrapped";
    paths = [ cava ];
    nativeBuildInputs = [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/cava \
        --add-flags "-p ${cavaConfig}"
    '';
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "qt-cava";
  version = "0.1.0";

  src = ./src;

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = with qt6; [
    qtbase
    qtdeclarative
  ];

  dontWrapQtApps = true;

  cmakeBuildType = "RelWithDebInfo";

  cmakeFlags = [
    (cmakeFeature "CAVA_BIN" "${cavaWithConfig}/bin/cava")
    (cmakeFeature "CAVA_BAR_COUNT" (toString cavaBarCount))
    (cmakeFeature "INSTALL_QMLDIR" "${placeholder "out"}/${qtQmlPrefix}")
    (cmakeFeature "INSTALL_QML_PREFIX" "${placeholder "out"}/${qtQmlPrefix}")
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/${qtQmlPrefix}/Cava
    cp -r libCavaPlugin.so libCavaPluginplugin.so qmldir *.qmltypes $out/${qtQmlPrefix}/Cava/

    runHook postInstall
  '';

  preFixup = ''
    patchelf \
      --set-rpath "$out/${qtQmlPrefix}/Cava:${makeLibraryPath finalAttrs.buildInputs}" \
      $out/${qtQmlPrefix}/Cava/libCavaPlugin.so

    patchelf \
      --set-rpath "$out/${qtQmlPrefix}/Cava:${makeLibraryPath finalAttrs.buildInputs}" \
      $out/${qtQmlPrefix}/Cava/libCavaPluginplugin.so
  '';

  meta = {
    description = "Cava audio visualizer raw stream QML plugin";
    platforms = linux;
  };
})
