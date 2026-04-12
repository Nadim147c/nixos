finputs: inal: prev: {
  writers = prev.writers // rec {
    # Append a newline to the text. Because the first line start
    # with shebang. And nushell concat the comment above the main
    # and shebang. This will ensure that shebang is not shown as
    # main function description.
    writeNu =
      let
        prefix = "\n# Big brother is watching you!\n\n";
      in
      name: argsOrScript:
      if prev.lib.isAttrs argsOrScript && !prev.lib.isDerivation argsOrScript then
        script: prev.writers.writeNu name argsOrScript (prefix + script)
      else
        prev.writers.writeNu name (prefix + argsOrScript);

    writeNuBin = name: writeNu "/bin/${name}";
  };
}
