{ createLuaKeymap, ... }:
{
  vim = {
    keymaps = [
      (createLuaKeymap "n" "<C-N>" /* lua */ ''
        function ()
          require("mini.files").open()
        end
      '')
    ];
    mini.files.enable = true;

    mini.files.setupOpts = {
      options = {
        permanent_delete = false;
        use_as_default_explorer = true;
      };
      mappings = {
        close = "q";
        go_in = "l";
        go_in_plus = "<CR>";
        go_out = "h";
        go_out_plus = "H";
        mark_goto = "'";
        mark_set = "m";
        reset = "<BS>";
        reveal_cwd = "@";
        show_help = "g?";
        synchronize = "=";
        trim_left = "<";
        trim_right = ">";
      };
      windows = {
        max_number = 10;
        preview = true;
        width_focus = 30;
        width_nofocus = 15;
        width_preview = 70;
      };
    };
  };
}
