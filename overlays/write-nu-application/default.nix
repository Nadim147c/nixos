finputs: inal: prev: {
  writeNuApplication =
    {
      name,
      runtimeInputs ? [ ],
      inheritPath ? true,
      text ? "",
      source ? "",
    }:
    let
      paths = runtimeInputs |> map (x: "${x}/bin") |> prev.lib.escapeShellArgs;

      prefix =
        if inheritPath then
          /* nu */ ''
            $env.PATH = $env.PATH ++ [ ${paths} ]
          ''
        else
          /* nu */ ''
            $env.PATH = [ ${paths} ]
          '';

      content = if (text != "") then text else builtins.readFile source;
    in
    prev.writers.writeNuBin name /* nu */ ''
      ${prefix}

      ${content}
    '';
}
