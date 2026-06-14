let
  name = "runix";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      completion.positionalany = [ "$files" ];
    };
    script =
      pkgs:
      pkgs.writeShellScriptBin name ''
        pkg=$1
        shift
        ${pkgs.coreutils}/bin/env \
          NIXPKGS_ALLOW_UNFREE=1 \
          NIXPKGS_ALLOW_BROKEN=1 \
          nix run --impure "nixpkgs#$pkg" -- "$@"
      '';
  };
}
