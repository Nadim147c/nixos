let
  name = "tmux-list-repos";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      flags = {
        "-d, --max-depth=" = "Maximum directory recursion depth";
      };
      completion = {
        positional = [ [ "$files" ] ];
      };
    };
    script =
      pkgs:
      pkgs.stdenv.mkDerivation {
        inherit name;

        src = ./tmux-list-repos.go;
        dontUnpack = true;

        nativeBuildInputs = with pkgs; [
          go
          writableTmpDirAsHomeHook
        ];

        buildPhase = ''
          runHook preBuild
          cp $src ./main.go
          go build -trimpath -o ${name} main.go
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
