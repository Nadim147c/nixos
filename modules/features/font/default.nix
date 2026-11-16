{
  self,
  lib,
  ...
}:

let
  inherit (lib.attrsets) attrValues;
  inherit (lib.lists) unique singleton;
  inherit (lib.modules) mkForce mkBefore mkIf;
  inherit (lib.x) opt;
in
{
  perSystem = { pkgs, self', ... }: {
    packages.fontconfig = pkgs.runCommand "fontconfig" { } ''
      mkdir -p $out/etc/fonts
      sed "s|${pkgs.dejavu_fonts.minimal}|${pkgs.noto-fonts}|" \
        "${pkgs.fontconfig.out}/etc/fonts/fonts.conf" > $out/etc/fonts/fonts.conf
    '';
    packages.systemFonts = pkgs.makeFontsConf {
      fontDirectories = attrValues {
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
        inherit (self'.packages)
          pixelarticons
          dseg_v046
          electroharmonix
          google-fonts
          ;
      };
    };
  };

  flake.tree.nixos.gui.font =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      cfg = config.font;
      inherit (self.packages.${system}) fontconfig;
    in
    {
      options.font = {
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
            inherit (self.packages.${system})
              pixelarticons
              dseg_v046
              electroharmonix
              google-fonts
              ;
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
                "Noto Sans Bengali"
                cfg.sans
                "Rubik"
                "Roboto"
                "Noto Sans"
              ];

              monospace = unique [
                cfg.mono
                "JetBrainsMono Nerd Font"
                "Roboto Mono"
                "monospace"
              ];

              serif = unique [
                "Noto Serif Bengali"
                cfg.serif
                "Roboto Serif"
                "Noto Serif"
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
