{ lib, ... }:
let
  inherit (lib) singleton;
  name = "control";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      parsing = "non-interspersed";
      flags = {
        "-c, --cpu=" = "CPU limit";
        "-m, --memory=" = "Memory limit";
        "-s, --scope" = "Run in terminal scope";
        "-h, --help" = "Print the help menu";
      };
      completion = {
        positional = singleton [ "$executables" ];
        positionalany = singleton "$carapace.bridge.CarapaceBin";
      };
    };
    script =
      pkgs:
      pkgs.stdenv.mkDerivation {
        inherit name;

        src = ./control.nim;
        dontUnpack = true;

        nativeBuildInputs = with pkgs; [
          nim
          pkg-config
          writableTmpDirAsHomeHook
        ];
        buildInputs = with pkgs; [
          glibc
          uwsm
        ];

        buildPhase = ''
          runHook preBuild
          cp $src ./main.nim
          nim c -d:release -d:uwsmBin=${lib.getExe pkgs.uwsm} main.nim
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          mv main $out/bin/${name}
          runHook postInstall
        '';

        meta.mainProgram = name;
      };
  };
}
