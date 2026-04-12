inputs: final: prev:
let
  goWriter =
    name:
    {
      strip ? true,
      trimpath ? true,
      cgo ? false,
      withDependencies ? true,
    }:
    let
      inherit (prev.lib)
        escapeShellArgs
        optional
        getExe
        ;

      args = optional trimpath "-trimpath" ++ optional strip "-ldflags=-s -w";
    in
    if withDependencies then
      writeWithDependencies (baseNameOf name) args
    else
      prev.writers.makeBinWriter {
        compileScript = /* bash */ ''
          cp "$contentPath" tmp.go
          export HOME=$NIX_BUILD_TOP/.home
          export CGO_ENABLED=${if cgo then "1" else "0"}
          ${getExe prev.go} build ${escapeShellArgs args} -o "$out" ./tmp.go
        '';
      } name;

  writeWithDependencies =
    name: args: script:
    let
      fs = prev.lib.fileset;
      src =
        prev.runCommand "${name}-go-source"
          {
            nativeBuildInputs = [ prev.go ];
            src = prev.lib.cleanSource (
              fs.toSource {
                root = ../../.;
                fileset = fs.unions [
                  ../../go.mod
                  ../../go.sum
                  ../../gomod2nix.toml
                ];
              }
            );

            inherit script;
          }
          ''
            mkdir -p $out/${name}
            cp $src/* $out/
            printf "%s" "$script" > $out/${name}/main.go
          '';

      gomod = inputs.gomod2nix.legacyPackages.${prev.stdenv.hostPlatform.system};
    in
    gomod.buildGoApplication {
      inherit name src;
      modules = ../../gomod2nix.toml;
      meta.mainProgram = name;
    };
in
{
  writers = prev.writers // rec {
    writeGo =
      name: argsOrScript:
      if prev.lib.isAttrs argsOrScript && !prev.lib.isDerivation argsOrScript then
        script: goWriter name argsOrScript script
      else
        goWriter name { } argsOrScript;
    writeGoBin = name: writeGo "/bin/${name}";
  };
}
