inputs: final: prev: {
  writers = prev.writers // {
    writeGo =
      name:
      {
        makeWrapperArgs ? [ ],
        runtimeInputs ? [ ],
        go ? prev.go,
        goArgs ? [ ],
        strip ? true,
      }:
      prev.writers.makeBinWriter {
        inherit strip;
        compileScript = ''
          cp "$contentPath" tmp.go
          export HOME=$NIX_BUILD_TOP/.home
          ${go}/bin/go build ${prev.lib.escapeShellArgs goArgs} -o "$out" tmp.go
        '';
        makeWrapperArgs =
          makeWrapperArgs
          ++ prev.lib.optionals (runtimeInputs != [ ]) [
            "--prefix"
            "PATH"
            ":"
            (prev.lib.makeBinPath runtimeInputs)
          ];
      } name;

    writeGoBin = name: final.writers.writeGo "/bin/${name}";
  };
}
