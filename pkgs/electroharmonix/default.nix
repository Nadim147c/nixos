{
  lib,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "electroharmonix";
  version = "unstable-2026-04-10"; # date +"unstable-%Y-%m-%d"
  src = ./Electroharmonix.otf;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/opentype
    cp $src $out/share/fonts/opentype/Electroharmonix.otf
    runHook postInstall
  '';

  meta = with lib; {
    description = "Fancy enlish font which looks like japanse";
    homepage = "https://www.dafont.com/electroharmonix.font";
    license = licenses.publicDomain;
    platforms = platforms.all;
  };
}
