_: {
  vim = {
    keymaps =
      let
        fzf = ''require("fzf-lua")'';
        function = body: "function () ${body} end";
        create = key: body: desc: {
          mode = "n";
          key = "<leader>f${key}";
          action = body;
          lua = true;
          desc = "fzf ${desc}";
        };
      in
      [
        (create "f" "${fzf}.files" "search files")
        (create "a" (function ''${fzf}.files { raw_cmd = "find" }'') "search all files")
        (create "b" "${fzf}.buffers" "search buffer")
        (create "g" "${fzf}.git_files" "search git files")
        (create "l" "${fzf}.git_commits" "search git commits")
        (create "q" "${fzf}.quickfix" "search quickfix list")
        (create "w" "${fzf}.live_grep" "live grep")
        (create "s" "${fzf}.grep_curbuf" "current buffer")
        (create "v" "${fzf}.highlights" "search highlights")
        (create "h" "${fzf}.help_tags" "search help")
      ];
    fzf-lua.enable = true;
    fzf-lua.setupOpts = {
      winopts = {
        height = 0.8;
        width = 0.8;
        preview = {
          horizontal = "right:50%";
        };
      };
      fzf_colors = {
        gutter = "-1";
      };
    };
  };
}
