{
  pkgs,
  ...
}:
{
  vim = {
    viAlias = true;
    vimAlias = true;

    theme = {
      enable = true;
      transparent = true;
      name = "catppuccin";
      style = "mocha";
    };

    extraPlugins =
      let
        inherit (pkgs.vimPlugins) direnv-vim nvim-surround;
      in
      {
        direnv.package = direnv-vim;
        nvim-surrond.package = nvim-surround;
      };

    diagnostics.enable = true;
    diagnostics.config = {
      underline = false;
      virtual_text = true;
      float.border = "rounded";
    };

    # autocmds
    luaConfigPost = /* lua */ ''
      -- use default colorscheme in tty
      -- https://github.com/catppuccin/nvim/issues/588#issuecomment-2272877967
      vim.g.has_ui = #vim.api.nvim_list_uis() > 0
      vim.g.has_gui = vim.g.has_ui and (vim.env.DISPLAY ~= nil or vim.env.WAYLAND_DISPLAY ~= nil)

      if not vim.g.has_gui then
        if vim.g.has_ui then
          vim.o.termguicolors = false
          vim.cmd.colorscheme('default')
        end
        return
      end


      vim.api.nvim_create_autocmd("TextYankPost", {
        group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
        desc = "Highlight selection on yank",
        callback = function()
          vim.highlight.on_yank({ timeout = 200, visual = true })
        end,
      })

      -- remove trailing whitespace on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        command = "silent! %s/\\s\\+$//e",
      })

      -- save on focus lost
      vim.api.nvim_create_autocmd("FocusLost", {
        pattern = "*",
        command = "silent! wa",
      })

      -- absolute line numbers in insert mode, relative otherwise
      vim.api.nvim_create_autocmd("InsertEnter", {
        pattern = "*",
        command = "set number norelativenumber",
      })
      vim.api.nvim_create_autocmd("InsertLeave", {
        pattern = "*",
        command = "set number relativenumber",
      })
    '';

    dashboard = {
      startify = {
        enable = true;
        changeToVCRoot = true;
      };
    };

    languages = {
      enableFormat = true;
      enableTreesitter = true;

      dart = {
        enable = true;
        flutter-tools.enable = true;
      };
      nu.enable = true;
      bash.enable = true;
      html.enable = true;
      lua.enable = true;
      markdown = {
        enable = true;
        extensions.render-markdown-nvim.enable = true;
      };
      nix = {
        enable = true;
        format = {
          enable = true;
          type = [ "nixfmt" ];
        };
        lsp.servers = [
          "nil"
          "nixd"
        ];
      };
      python.enable = true;
      rust.enable = true;
      typescript.enable = true;
      qml = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
      };
    };

    lsp = {
      enable = true;
      formatOnSave = true;
      # lightbulb.enable = true;
      lspkind.enable = true;
      presets = {
        tailwindcss-language-server.enable = true;
        typescript-go.enable = true;
      };
      otter-nvim.enable = true; # provide lsp for embedded languages
      trouble.enable = true;
    };

    autopairs.nvim-autopairs.enable = true;
    binds.whichKey.enable = true;
    mini = {
      align.enable = true;
      indentscope.enable = true;
    };

    # filetree.nvimTree = {
    #   enable = true;
    #   openOnSetup = false;
    # };
    git.enable = true;

    # enable dashboard?
    lazy.enable = true;
    snippets.luasnip.enable = true;
    statusline.lualine.enable = true;

    treesitter.autotagHtml = true;
    treesitter.textobjects = {
      enable = true;
      setupOpts = {

        lookahead = true;
        keymaps = {
          "af" = "@function.outer";
          "if" = "@function.inner";
          "ac" = "@class.outer";
          "ic" = "@class.inner";
        };
        selection_modes = {
          "@parameter.outer" = "v"; # charwise
          "@function.outer" = "V"; # linewise
          "@class.outer" = "<c-v>"; # blockwise
        };
        include_surrounding_whitespace = true;
      };
    };
    ui = {
      colorizer.enable = true;
      smartcolumn.enable = true;
    };
    utility = {
      undotree.enable = true;
      motion.leap.enable = true;
    };
    visuals.nvim-web-devicons.enable = true;
  };
}
