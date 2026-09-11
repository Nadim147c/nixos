{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  installFonts,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pixelarticons";
  version = "2.4.0";

  outputs = [
    "out"
    "webfont"
  ];

  src = fetchFromGitHub {
    owner = "halfmage";
    repo = "pixelarticons";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DHmTEw74pp3cvlacGYMCKJPflkuFWlOjzgGFBGrnndY=";
  };

  nativeBuildInputs = [
    (python3.withPackages (ps: [ ps.fontforge ]))
    installFonts
  ];

  buildPhase = ''
    runHook preBuild
    python3 ${./generate-font.py}
    runHook postBuild
  '';

  meta = with lib; {
    description = "Pixel art icons font with ligature support";
    homepage = "https://github.com/halfmage/pixelarticons";
    license = licenses.mit;
    platforms = platforms.all;
  };
})
