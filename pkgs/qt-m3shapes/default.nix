{
  cmake,
  fetchFromGitHub,
  lib,
  ninja,
  qt6,
  stdenv,
}:
let
  prefix = qt6.qtbase.qtQmlPrefix;
in
stdenv.mkDerivation rec {
  pname = "qt-m3shapes";
  version = "0-unstable-2026-06-09";

  src = fetchFromGitHub {
    owner = "soramanew";
    repo = "m3shapes";
    rev = "bdc327b29f95394a732baf3c9b19658ba23755b6";
    hash = "sha256-kfHyzZaPHgqZML48OA+5JwBOsLdQJ2ci/aGPShvUB4Y=";
  };

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
    (lib.cmakeFeature "INSTALL_QMLDIR" "${placeholder "out"}/${prefix}")
    (lib.cmakeFeature "INSTALL_QML_PREFIX" "${placeholder "out"}/${prefix}")
  ];

  postFixup = ''
    patchelf \
      --set-rpath "$out/${prefix}/M3Shapes:${lib.makeLibraryPath buildInputs}" \
      $out/${prefix}/M3Shapes/libm3shapesplugin.so
  '';

  meta = {
    description = "A QT port of the androidx shape library";
    homepage = "https://github.com/soramanew/m3shapes";
    platforms = lib.platforms.linux;
  };
}
