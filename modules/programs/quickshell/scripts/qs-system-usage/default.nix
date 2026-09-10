let
  name = "qs-system-usage";
in
{
  scripts."${name}" = rec {
    inherit name;
    script =
      pkgs:
      pkgs.stdenv.mkDerivation {
        inherit name;

        src = ./src;
        dontUnpack = true;

        nativeBuildInputs = with pkgs; [
          nim
          pkg-config
          writableTmpDirAsHomeHook
        ];
        buildInputs = with pkgs; [
          glib
          procps
        ];

        buildPhase = ''
          runHook preBuild
          cp $src/* ./
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
