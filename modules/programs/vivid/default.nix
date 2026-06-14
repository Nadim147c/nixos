{
  flake.modules.nixos.base = {
    programs.vivid = {
      enable = true;
      theme = "ansi";
    };
  };
}
