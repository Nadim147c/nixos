{
  flake.modules.neovim.base.vim = {
    clipboard = {
      enable = true;
      registers = "unnamed,unnamedplus";
      providers = {
        wl-copy.enable = true;
        xclip.enable = true;
      };
    };
    lineNumberMode = "relNumber";
    preventJunkFiles = true;
    searchCase = "smart";
    options = {
      # cursorline = true;
      gdefault = true;
      magic = true;
      matchtime = 2; # briefly jump to a matching bracket for 0.2s
      exrc = true; # use project specific vimrc
      smartindent = true;
      autoindent = true;
      virtualedit = "block"; # allow cursor to move anywhere in visual block mode
      # Use 4 spaces for <Tab> and :retab
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      shiftround = true; # round indent to multiple of 'shiftwidth' for > and < command
      winborder = "rounded";
      fileformat = "unix";
    };
  };
}
