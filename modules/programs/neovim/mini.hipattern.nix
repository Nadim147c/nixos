{ lib, ... }:
let
  createHighlight = pattern: group: { inherit pattern group; };
in
{
  flake.modules.neovim.base.vim = {
    mini.hipatterns = {
      enable = true;
      setupOpts = {
        highlighters = {
          fixme = createHighlight "%f[%w]()FIXME()%f[%W]" "MiniHipatternsFixme";
          hack = createHighlight "%f[%w]()HACK()%f[%W]" "MiniHipatternsHack";
          todo = createHighlight "%f[%w]()TODO()%f[%W]" "MiniHipatternsTodo";
          note = createHighlight "%f[%w]()NOTE()%f[%W]" "MiniHipatternsNote";
          hex_color = lib.generators.mkLuaInline /* lua */ ''
            require("mini.hipatterns").gen_highlighter.hex_color()
          '';
        };
      };
    };
  };
}
