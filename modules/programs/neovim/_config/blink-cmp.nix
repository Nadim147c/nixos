_: {
  vim = {
    autocomplete.blink-cmp = {
      enable = true;
      mappings = {
        complete = "<Tab>";
        next = "<C-N>";
        previous = "<C-P>";
      };
      setupOpts.cmdline.keymap.preset = "inherit";
    };
  };
}
