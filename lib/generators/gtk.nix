final: lib:
# Copied from https://github.com/snugnug/hjem-rum/blob/4194064c687bf6ca7a79cbe127cbe5a3f51ed5d5/modules/lib/generators/gtk.nix [GPL-v3]
let
  inherit (builtins) isBool isString;
  inherit (lib.strings) hasPrefix concatStringsSep;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.trivial) boolToString;
  inherit (lib.generators) toINI;
in
{
  toGtk2Text =
    let
      formatGtk2 =
        n: v:
        let
          n' = if hasPrefix "gtk-" n then n else "gtk-" + n;
          v' =
            if isBool v then
              boolToString v
            else if isString v then
              if hasPrefix "GTK_" v then v else ''"${v}"''
            else
              toString v;
        in
        "${n'}=${v'}";
    in
    { settings }:
    concatStringsSep "\n" (mapAttrsToList formatGtk2 settings);
  toGtkINI =
    attrs:
    toINI {
      mkKeyValue =
        n: v:
        let
          n' = if hasPrefix "gtk-" n then n else "gtk-" + n;
          v' = if isBool v then boolToString v else toString v;
        in
        "${n'}=${v'}";
    } attrs;
}
