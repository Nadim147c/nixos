{ lib, ... }:
let
  inherit (lib) singleton;
  inherit (lib.generators) mkLuaInline;
in
{
  flake.modules.neovim.base.vim = {
    diagnostics = {
      enable = true;
      config = {
        underline = false;
        virtual_text = true;
        float.border = "rounded";
      };
      nvim-lint.enable = true;

      nvim-lint.linters_by_ft = {
        go = singleton "golangci-lint";
      };
      presets.golangci-lint.enable = true;
      nvim-lint.linters.golangci-lint.required_files = [
        ".golangci.yml"
        ".golangci.yaml"
        ".golangci.toml"
        ".golangci.json"
      ];
    };

    languages = {
      enableFormat = true;
      enableTreesitter = true;

      sql = {
        enable = true;
        lsp.enable = false;
        format.enable = false;
      };
      bash.enable = true;
      html.enable = true;
      zig.enable = true;
      go = {
        enable = true;
        extensions.gopher-nvim.enable = true;
      };
      lua = {
        enable = true;
        format.enable = true;
      };
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
      nu.enable = true;
      python = {
        enable = true;
        format = {
          enable = true;
          type = [
            "black"
            "isort"
          ];
        };
      };
      qml = {
        enable = true;
        format.enable = true;
        lsp.enable = true;
      };
      typescript.enable = true;
    };

    lsp = {
      enable = true;
      formatOnSave = true;
      inlayHints.enable = true;
      lspkind.enable = true;
      presets = {
        tailwindcss-language-server.enable = true;
        typescript-go.enable = true;
        harper.enable = true;
      };
      otter-nvim.enable = true;
      servers.nixd = {
        settings.options = {
          nixos.expr = /* nix */ ''
            let
              pkgs = import <nixpkgs> {};
              hostname =pkgs.lib.trim <| builtins.readFile /etc/hostname;
            in
              (builtins.getFlake .).nixosConfigurations.''${hostname}.options"
          '';
          nixpkgs.expr = /* nix */ "import <nixpkgs> {}";
        };
      };
      servers."*" = {
        on_attach = mkLuaInline /* lua */ ''
          function(_, bufnr)
            local function opts(desc)
              return { buffer = bufnr, desc = "LSP " .. desc }
            end

            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
            vim.keymap.set("n", "H", vim.diagnostic.open_float, opts("Show diagnostic in a float"))
            vim.keymap.set("n", "gn", vim.diagnostic.goto_next, opts("Go to next diagnostic"))
            vim.keymap.set("n", "gN", vim.diagnostic.goto_prev, opts("Go to previous diagnostic"))
            vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, opts("Show signature help"))
            vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts("Add workspace folder"))
            vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts("Remove workspace folder"))
            vim.keymap.set("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

            vim.keymap.set("n", "<leader>wl", function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, opts("List workspace folders"))

            vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts("Go to type definition"))

            vim.keymap.set("n", "<leader>ra", vim.lsp.buf.rename, { expr = true })

            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("Code action"))
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("Show references"))
          end
        '';
      };
    };
  };
}
