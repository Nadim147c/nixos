{

  flake.modules.nixos.base = {
    environment.pathsToLink = [
      "/share/fish/vendor_completions.d"
    ];

    programs.fish = {
      enable = true;
      useBabelfish = true;
      generateCompletions = false;
      interactiveShellInit = /* fish */ ''
        set -U fish_greeting
        set fish_color_command blue --bold
        set fish_color_redirection yellow --bold
        set fish_color_option red
        set fish_pager_color_prefix green --bold
        set fish_pager_color_completion blue --bold
        set fish_pager_color_description white --bold

        fish_vi_key_bindings --no-erase
      '';
    };
  };
}
