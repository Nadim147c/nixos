finputs: inal: prev: {
  mkInitScript =
    name: script:
    let
      inlined = prev.lib.escapeShellArg script;
    in
    prev.runCommand name
      {
        nativeBuildInputs = with prev; [
          sd
          ripgrep
          writableTmpDirAsHomeHook
        ];
      }
      ''
        bash -c ${inlined} > $out
      '';
}
