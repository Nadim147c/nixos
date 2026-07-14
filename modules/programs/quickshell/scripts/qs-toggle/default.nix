let
  name = "qs-toggle";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      pkgs.writeShellScriptBin name ''
        id=$(qs list --all --json | ${pkgs.jq}/bin/jq .[0].id -r | ${pkgs.coreutils}/bin/head -n 1)
        qs ipc -i "$id" call toggle set "$@"
      '';
  };
}
