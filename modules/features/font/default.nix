{ self, lib, ... }:
let
  inherit (lib)
    attrValues
    unique
    singleton
    mkForce
    mkBefore
    mkIf
    ;
  inherit (lib.x) opt;
in
{
  perSystem = { pkgs, ... }: {
    packages.fontconfig = pkgs.runCommand "fontconfig" { } ''
      mkdir -p $out/etc/fonts
      sed "s|${pkgs.dejavu_fonts.minimal}|${pkgs.noto-fonts}|" \
        "${pkgs.fontconfig.out}/etc/fonts/fonts.conf" > $out/etc/fonts/fonts.conf
    '';
  };

  flake.modules.nixos.gui = {
    custom.font.enable = true;
  };

  flake.modules.nixos.base =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      cfg = config.custom.font;
      inherit (self.packages.${system})
        fontconfig
        ;
    in
    {
      options.custom.font = {
        enable = opt.bool true;
        sans = opt.line "Rubik";
        serif = opt.line "Roboto Serif";
        mono = opt.line "JetBrainsMono Nerd Font";
        size = opt.num 10;
      };

      config = mkIf cfg.enable {
        environment.pathsToLink = singleton "/share/fonts";
        fonts = {
          fontDir.enable = true;
          enableDefaultPackages = mkForce false;
          packages = attrValues {
            inherit (pkgs)
              material-symbols
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
              ;
            inherit (pkgs.nerd-fonts) jetbrains-mono;
            inherit (self.packages.${system}) electroharmonix google-fonts;
          };
          fontconfig = {
            inherit (cfg) enable;
            antialias = true;
            hinting.enable = true;
            allowBitmaps = true;
            useEmbeddedBitmaps = true;
            cache32Bit = true;
            confPackages = mkBefore <| singleton fontconfig;
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
                "Noto Color Emoji"
                "Twitter Color Emoji"
              ];
            };
          };
        };
      };
    };
}
