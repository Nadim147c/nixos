{
  lib,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "google-fonts";
  version = "0-unstable-2026-09-06"; # date +"0-unstable-%Y-%m-%d"
  src = lib.cleanSource (
    lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./Anton
        ./Gabarito
        ./Space_Grotesk
        ./Pixelify_Sans
        ./Silkscreen
      ];
    }
  );

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/opentype
    find $src -name "*.ttf" -exec install -m 444 -Dt $out/share/fonts/opentype/ '{}' +
    runHook postInstall
  '';

  meta = with lib; {
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
