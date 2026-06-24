inputs: final: pkgs: rec {
  impurify' =
    package: args:
    let
      inherit (pkgs.lib) getExe toList;
      fullname = getExe package;
      basename = baseNameOf fullname;
    in
    inputs.wrappers.lib.wrapPackage (
      {
        inherit package pkgs;
        runShell = toList /* bash */ ''
          override="$HOME/.local/bin/${basename}"
          binName=$([[ -x "$override" ]] && "$override" || "${fullname}")
        '';
        argv0type = _: ''
          exec -a "${basename}" "$binName" "$@"
        '';
      }
      // args
    );
  impurify = package: impurify' package { };
}
