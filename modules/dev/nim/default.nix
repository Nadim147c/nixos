{ lib, ... }:
let
  inherit (lib) singleton;
  inherit (lib.trivial) const;
  inherit (lib.attrsets) filterAttrs;
  inherit (lib.generators) toKeyValue toINI;
  inherit (builtins) isAttrs;
in
{
  flake.modules.nixos.dev =
    { config, pkgs, ... }:
    let
      cfg = config.dev.nim;
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
      options.dev.nim.enable = lib.x.opt.bool true;

      config = lib.mkIf cfg.enable {
        packages = with pkgs; [
          nim
          nimble
        ];

        preserveHome.directories = singleton ".local/share/nimble";

        hj.xdg.config.files."nimble/nimble.ini" = {
          generator = generateNimINI;
          value = {
            nimbleDir = "${config.hj.xdg.data.directory}/nimble";
          };
        };
      };
    };
}
