let
  name = "qs-mpris-monitor";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      pkgs.stdenv.mkDerivation {
        name = "qs-mpris-monitor";

        src = ./qs-mpris-monitor.nim;
        dontUnpack = true;

        nativeBuildInputs = with pkgs; [
          nim
          pkg-config
          writableTmpDirAsHomeHook
        ];
        buildInputs = [ pkgs.glib ];

        buildPhase = ''
          runHook preBuild
          cp $src ./main.nim
          nim c -d:release main.nim
          runHook postBuild
        '';

        installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            mv main $out/bin/${name}
          runHook postInstall
        '';
      };
  };
}
