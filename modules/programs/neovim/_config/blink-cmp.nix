{ lib, ... }:
let
  inherit (lib) toList;
  inherit (lib.generators) mkLuaInline;
  fallback = x: (toList x) ++ [ "fallback" ];
  cmp = ''require("blink.cmp")'';
in
{
  vim = {
    autocomplete.blink-cmp = {
      enable = true;
      setupOpts = {
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

        cmdline.keymap = {
          "<Up>" = fallback <| (mkLuaInline "function() ${cmp}.select_prev { auto_insert = true } end");
          "<C-p>" = fallback <| (mkLuaInline "function() ${cmp}.select_prev { auto_insert = true } end");
          "<Down>" = fallback <| (mkLuaInline "function() ${cmp}.select_next { auto_insert = true } end");
          "<C-n>" = fallback <| (mkLuaInline "function() ${cmp}.select_next { auto_insert = true } end");
        };
      };
    };
  };
}
