inputs: final: prev:
let
  inherit (prev.lib)
    isBool
    isAttrs
    isDerivation
    cleanSource
    fileset
    escapeShellArg
    makeBinPath
    ;

  goWriter =
    path:
    {
      runtimeInputs ? [ ],
      inheritPath ? false,
    }:
    script:
    assert (isBool inheritPath);
    let
      name = baseNameOf path;
      env = /* go */ ''
        package main

        import (
        	"os"
        	"path/filepath"
        	"slices"
        	"strings"
        )

        const (
        	prefixPaths  = "${makeBinPath runtimeInputs}"
        	inheritPaths = ${builtins.toJSON inheritPath}
        )

        func init() {
        	paths := filepath.SplitList(prefixPaths)
        	if inheritPaths {
        		paths = append(paths, filepath.SplitList(os.Getenv("PATH"))...)
        	}
        	final := slices.DeleteFunc(paths, func(s string) bool { return s == "" })
        	err := os.Setenv("PATH", strings.Join(final, string(filepath.ListSeparator)))
        	if err != nil {
        		panic(err)
        	}
        }
      '';

      cleanSrc = cleanSource (
        fileset.toSource {
          root = ../../.;
          fileset = fileset.unions [
            ../../go.mod
            ../../go.sum
            ../../gomod2nix.toml
          ];
        }
      );

      src = prev.runCommand "${name}-go-source" { } ''
        mkdir -p $out/${name}
        cp ${cleanSrc}/* $out/
        printf "%s" ${escapeShellArg script} > $out/${name}/main.go
        printf "%s" ${escapeShellArg env} > $out/${name}/env.go
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
      if isAttrs argsOrScript && !isDerivation argsOrScript then
        script: goWriter name argsOrScript script
      else
        goWriter name { } argsOrScript;
    writeGoBin = name: writeGo "/bin/${name}";
  };
}
