let
  name = "qs-gpu-screen-record";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      pkgs.stdenv.mkDerivation {
        inherit name;

        src = ./qs_gpu_screen_record.go;
        dontUnpack = true;

        nativeBuildInputs = with pkgs; [
          go
          writableTmpDirAsHomeHook
        ];

        buildPhase = ''
          runHook preBuild
          cp $src ./main.go
          go build -trimpath -o ${name} -ldflags="-X main.debug=true" main.go
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          install -Ds ${name} $out/bin/${name}
          runHook postInstall
        '';

        meta.mainProgram = name;
      };
  };
}
