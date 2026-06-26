{ pkgs, ... }: {
  vim = {
    keymaps =
      let
        fzf = ''require("fzf-lua")'';
        fff = ''require("fff")'';
        create = key: body: desc: {
          mode = "n";
          key = "<leader>f${key}";
          action = "function () ${body} end";
          lua = true;
          desc = "fzf ${desc}";
        };
      in
      [
        (create "f" "${fff}.find_files()" "search files")
        (create "w" "${fff}.live_grep()" "live grep")
        (create "u" "${fff}.live_grep { grep = {'fuzzy', 'plain'} }" "live grep")

        (create "a" ''${fzf}.files { raw_cmd = "find" }'' "search all files")
        (create "b" "${fzf}.buffers()" "search buffer")
        (create "g" "${fzf}.git_files()" "search git files")
        (create "l" "${fzf}.git_commits()" "search git commits")
        (create "q" "${fzf}.quickfix()" "search quickfix list")
        (create "s" "${fzf}.grep_curbuf()" "current buffer")
        (create "v" "${fzf}.highlights()" "search highlights")
        (create "h" "${fzf}.help_tags()" "search help")
      ];

    extraPlugins.fff-nvim = {
      package = pkgs.vimPlugins.fff-nvim;
      setup = /* lua */ ''
        require('fff').setup({
          base_path = vim.fn.getcwd(),
          prompt = '> ',
          title = 'FFFiles',
          max_results = 100,
          max_threads = 4,
          lazy_sync = true,
          follow_symlinks = false,
          -- Allow indexing the user's $HOME directory. Enabled by default.
          -- Disable if you strictly sure you don't want this, as it makes whole fff error hard
          enable_home_dir_scanning = true,
          -- Allow indexing a filesystem root (e.g. `/`, `C:\`). Disabled by default
          enable_fs_root_scanning = false,
          layout = {
            height = 0.8,
            width = 0.8,
            prompt_position = 'top',   -- or 'top'
          },
          frecency = {
            enabled = true,
            db_path = vim.fn.stdpath('cache') .. '/fff_nvim',
          },
          history = {
            enabled = true,
            db_path = vim.fn.stdpath('data') .. '/fff_queries',
          },
        })
      '';
    };
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
