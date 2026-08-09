{
  cmake,
  lib,
  ninja,
  qt6,
  stdenv,
}:
let
  inherit (qt6.qtbase) qtQmlPrefix;
  inherit (lib) makeLibraryPath cmakeFeature;
  inherit (lib.platforms) linux;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "qt-oklab";
  version = "0-unstable-2026-06-09";

  src = ./src;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = with qt6; [
    qtbase
    qtdeclarative
  ];

  dontWrapQtApps = true;

  cmakeBuildType = "RelWithDebInfo";

  cmakeFlags = [
    (cmakeFeature "INSTALL_QMLDIR" "${placeholder "out"}/${qtQmlPrefix}")
    (cmakeFeature "INSTALL_QML_PREFIX" "${placeholder "out"}/${qtQmlPrefix}")
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/${qtQmlPrefix}/OkLab
    cp -r libOkLabPlugin.so libOkLabPluginplugin.so qmldir *.qmltypes $out/${qtQmlPrefix}/OkLab/

    runHook postInstall
  '';

  postFixup = ''
    patchelf \
      --set-rpath "$out/${qtQmlPrefix}/OkLab:${makeLibraryPath finalAttrs.buildInputs}" \
      $out/${qtQmlPrefix}/OkLab/libOkLabPlugin.so

    patchelf \
      --set-rpath "$out/${qtQmlPrefix}/OkLab:${makeLibraryPath finalAttrs.buildInputs}" \
      $out/${qtQmlPrefix}/OkLab/libOkLabPluginplugin.so
  '';

  meta = {
    description = "A QT port of the androidx shape library";
    homepage = "https://github.com/soramanew/m3shapes";
    platforms = linux;
  };
})
