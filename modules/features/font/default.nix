{ self, lib, ... }:
let
  option = {
    options.custom.font = {
      enable = lib.x.opt.bool false;
      sans = lib.x.opt.line "Roboto Flex";
      serif = lib.x.opt.line "Roboto Serif";
      mono = lib.x.opt.line "JetBrainsMono Nerd Font";
      size = lib.x.opt.num 10;
    };
  };
in
{
  flake.modules = {
    nixos.base = option;
    homeManager.base = option;
    nixos.gui =
      { config, ... }:
      {
        custom.font.enable = true;
        home.custom.font = config.custom.font;
      };

    homeManager.gui =
      {
        config,
        pkgs,
        system,
        ...
      }:
      let
        cfg = config.custom.font;
        inherit (lib) unique;
        inherit (self.packages.${system})
          electroharmonix
          google-fonts
          ;
      in
      lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          electroharmonix
          fontconfig
          material-symbols
          google-fonts
          nerd-fonts.jetbrains-mono
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
          roboto
          roboto-flex
          roboto-mono
          roboto-serif
          roboto-slab
          twemoji-color-font
        ];

        fonts.fontconfig = {
          inherit (cfg) enable;
          antialiasing = true;
          hinting = "slight";
          defaultFonts = {
            sansSerif = unique [
              cfg.sans
              "Rubik"
              "Roboto"
              "Noto Sans"
              "Noto Sans Bengali"
            ];

            monospace = unique [
              cfg.mono
              "JetBrainsMono Nerd Font"
              "Roboto Mono"
              "monospace"
            ];

            serif = unique [
              cfg.serif
              "Roboto Serif"
              "Noto Serif"
              "Noto Serif Bengali"
            ];

            emoji = [
              "Twitter Color Emoji"
              "Noto Color Emoji"
              "Twemoji"
            ];
          };
        };
      };
  };
}
