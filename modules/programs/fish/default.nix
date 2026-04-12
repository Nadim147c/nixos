{

  flake.modules.nixos.base.environment.pathsToLink = [
    "/share/fish/vendor_completions.d"
  ];

  flake.modules.homeManager.base = {
    programs.fish = {
      enable = true;
      interactiveShellInit = /* fish */ ''
        set -U fish_greeting
        set fish_color_command blue --bold
        set fish_color_redirection yellow --bold
        set fish_color_option red
        set fish_pager_color_prefix green --bold
        set fish_pager_color_completion blue --bold
        set fish_pager_color_description white --bold
      '';
      generateCompletions = false;
      functions.fish_user_key_bindings.body = /* fish */ ''
        fish_vi_key_bindings --no-erase
      '';
    };

  };

}
