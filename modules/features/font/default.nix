{ self, lib, ... }:
let
  inherit (lib)
    unique
    toList
    mkForce
    mkBefore
    ;
in
{
  perSystem = { pkgs, ... }: {
    packages.fontconfig = pkgs.runCommand "fontconfig" { } ''
      mkdir -p $out/etc/fonts
      sed "s|${pkgs.dejavu_fonts.minimal}|${pkgs.noto-fonts}|" \
        "${pkgs.fontconfig.out}/etc/fonts/fonts.conf" > $out/etc/fonts/fonts.conf
    '';
  };
  flake.modules.nixos.gui =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      cfg = config.custom.font;
      inherit (self.packages.${system})
        electroharmonix
        google-fonts
        fontconfig
        ;
    in
    {
      options.custom.font = {
        enable = lib.x.opt.bool true;
        sans = lib.x.opt.line "Roboto Flex";
        serif = lib.x.opt.line "Roboto Serif";
        mono = lib.x.opt.line "JetBrainsMono Nerd Font";
        size = lib.x.opt.num 10;
      };

      config = lib.mkIf cfg.enable {
        environment.pathsToLink = toList "/share/fonts";
        fonts = {
          fontDir.enable = true;
          enableDefaultPackages = mkForce false;
          packages = with pkgs; [
            electroharmonix
            google-fonts
            material-symbols
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
          fontconfig = {
            inherit (cfg) enable;
            antialias = true;
            hinting.enable = true;
            allowBitmaps = true;
            useEmbeddedBitmaps = true;
            cache32Bit = true;
            confPackages = mkBefore [ fontconfig ];
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
