{
  fetchurl,
  jre,
  lib,
  libGL,
  makeDesktopItem,
  makeWrapper,
  stdenv,
  unzip,
  wrapGAppsHook3,
}:
let
  inherit (lib) toList escapeShellArg;
  inherit (lib.licenses) gpl3Only;
  inherit (lib.sourceTypes) binaryBytecode;
in
stdenv.mkDerivation (finalAttr: {
  pname = "morphe-cli";
  version = "1.9.0";

  src = fetchurl {
    url = "https://github.com/MorpheApp/morphe-cli/releases/download/v${finalAttr.version}/morphe-cli-${finalAttr.version}-all.jar";
    hash = "sha256-cHxWaqqEqMY6Log6ccsep/VeHjwIjEJs0Gss0fl9Pmk=";
  };

  strictDeps = true;

  desktopItems = toList (makeDesktopItem {
    name = "morphe";
    exec = "morphe-cli";
    icon = "ingsoc";
    desktopName = "Morphe";
    genericName = "Software patcher";
    categories = [ "Development" ];
  });

  nativeBuildInputs = [
    unzip
    wrapGAppsHook3
    makeWrapper
  ];
  buildInputs = [
    jre
    libGL
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$prefix/bin" "$out/share/doc/morphe-cli" "$out/share/morphe-cli"
    install -Dm644 "$src" $out/share/morphe-cli/morphe-cli.jar

    makeWrapper ${jre}/bin/java $out/bin/morphe-cli \
      --add-flags "-jar $out/share/morphe-cli/morphe-cli.jar" \
      --run 'export HOME=$(mktemp -d)' \
      --run 'export JAVA_TOOL_OPTIONS="-Duser.home=$HOME"' \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL ]}" \

    unzip -p "$src" NOTICE > "$out/share/doc/morphe-cli/NOTICE"

    runHook postInstall
  '';

  meta = {
    description = "An application that patches android application";
    homepage = "https://github.com/MorpheApp/morphe-cli";
    license = gpl3Only;
    sourceProvenance = toList binaryBytecode;
    maintainers = toList lib.maintainers.hetraeus;
    mainProgram = "morphe-cli";
  };
})
