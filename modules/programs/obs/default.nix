{
  flake.tree.nixos.gui.obs = { pkgs, ... }: {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-vaapi
        obs-mute-filter
        obs-tuna
        obs-pipewire-audio-capture
      ];
    };
  };
}
