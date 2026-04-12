_: {
  flake.modules.nixos.pc =
    { pkgs, ... }:
    {
      boot.plymouth = {
        enable = true;
        font = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFont-Regular.ttf";
        logo = "${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake-white.png";
        theme = "breeze";
      };
    };
}
