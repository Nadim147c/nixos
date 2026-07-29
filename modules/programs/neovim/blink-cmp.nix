{ lib, ... }:
let
  inherit (lib) toList;
  inherit (lib.generators) mkLuaInline;
  fallback = x: (toList x) ++ [ "fallback" ];
  cmp = ''require("blink.cmp")'';
in
{
  flake.modules.neovim.base.vim = {
    autocomplete.blink-cmp = {
      enable = true;
      setupOpts = {
        completion.documentation.auto_show = true;
        keymap = {
          "<C-k>" = [
            "show"
            "show_documentation"
            "hide_documentation"
          ];
          "<C-e>" = fallback "hide";
          "<CR>" = fallback "select_and_accept";
          "<Up>" = fallback "select_prev";
          "<Down>" = fallback "select_next";
          "<C-p>" = fallback "select_prev";
          "<C-n>" = fallback "select_next";
          "<Tab>" = fallback "snippet_forward";
          "<S-Tab>" = fallback "snippet_backward";
        };

        cmdline = {
          menu.auto_show = true;
          keymap = {
            "<Up>" = fallback <| (mkLuaInline "function() ${cmp}.select_prev { auto_insert = false } end");
            "<C-p>" = fallback <| (mkLuaInline "function() ${cmp}.select_prev { auto_insert = false } end");
            "<Down>" = fallback <| (mkLuaInline "function() ${cmp}.select_next { auto_insert = false } end");
            "<C-n>" = fallback <| (mkLuaInline "function() ${cmp}.select_next { auto_insert = false } end");
            "<CR>" = fallback "select_and_accept";
          };
        };
      };
    };
  };
}
