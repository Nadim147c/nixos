{ lib, ... }:
let
  option =
    { pkgs, ... }:
    {
      options.custom = {
        cursor = {
          package = lib.x.opt.pkg pkgs.bibata-cursors;
          name = lib.x.opt.line "Bibata-Modern-Classic";
          size = lib.x.opt.int 32;
        };
      };
    };
in
{
  flake.modules = {
    nixos.base = option;
    homeManager.base = option;

    nixos.gui =
      { config, ... }:
      {
        environment.systemPackages = [ config.custom.cursor.package ];
        home.custom.cursor = config.custom.cursor;
      };

    homeManager.gui =
      { config, ... }:
      {
        home.pointerCursor = {
          enable = true;
          gtk.enable = true;
          hyprcursor.enable = true;
          inherit (config.custom.cursor) name package size;
        };
      };
  };
}
