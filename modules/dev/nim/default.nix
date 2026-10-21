{ lib, ... }:
let
  inherit (lib.attrsets) filterAttrs;
  inherit (lib.generators) toKeyValue toINI;
  inherit (lib.lists) singleton;
  inherit (lib.trivial) const;
  inherit (builtins) isAttrs;
in
{
  flake.tree.nixos.dev.nim =
    { config, pkgs, ... }:
    let
      isNotAttrs = value: (isAttrs value) == false;
      mkKeyValue = name: value: ''${name} = r"${value}"'';
      generateNimINI =
        attrs:
        let
          unnested = filterAttrs (const isNotAttrs) attrs;
          nested = filterAttrs (const isAttrs) attrs;
        in
        toKeyValue { inherit mkKeyValue; } unnested + "\n" + toINI { inherit mkKeyValue; } nested;
    in
    {
      packages = with pkgs; [
        nim
        nimble
      ];

      hj.xdg.config.files."nimble/nimble.ini" = {
        generator = generateNimINI;
        value = {
          nimbleDir = "${config.hj.xdg.data.directory}/nimble";
        };
      };
    };
}
