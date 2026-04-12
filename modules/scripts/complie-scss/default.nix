{
  lib,
  ...
}:
let
  name = "compile-scss";
in
{
  scripts."${name}" = rec {
    inherit name;
    completion = {
      inherit name;
      completion.positional = [
        [ "$files" ]
        [ "$files" ]
      ];
    };
    script =
      pkgs:
      pkgs.writeShellScriptBin name ''
        input="$1"
        output=$(echo "$input" | sed 's/scss$/css/')
        ${lib.getExe pkgs.dart-sass} --no-source-map "$input:$output"
      '';
  };
}
