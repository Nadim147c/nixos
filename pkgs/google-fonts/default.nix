{
  lib,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "google-fonts";
  version = "unstable-2026-05-14"; # date +"unstable-%Y-%m-%d"
  src = lib.cleanSource (
    lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./Anton
        ./Gabarito
        ./Space_Grotesk
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
    description = "Fancy enlish font which looks like japanse";
    homepage = "https://www.dafont.com/electroharmonix.font";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
