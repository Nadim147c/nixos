{ lib, ... }:
let
  inherit (lib) mkOption mapAttrsToList types;
  inherit (lib.x) opt;
in
{
  flake.modules.nixos.base =
    { config, ... }:
    let
      cfg = config.displays;
    in
    {
      options.displays = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              enable = opt.bool true;
              primary = opt.bool ((lib.attrValues cfg |> builtins.length) == 1);
              refreshRate = opt.num 60;
              width = opt.int 1920;
              height = opt.int 1080;
              x = opt.int 0;
              y = opt.int 0;
              extra = opt.attrs.any { };
            };
          }
        );
        default = { };
      };

      config = {
        boot.kernelParams =
          let
            createKernelFlag =
              name: display:
              if display.enable then
                with display; "video=${name}:${toString width}x${toString height}@${toString refreshRate}"
              else
                "video=${name}:d";
          in
          mapAttrsToList createKernelFlag cfg;
      };
    };
}
