{ self, lib, ... }:
let
  inherit (lib) getExe getExe';
in
{
  flake.modules.nixos.base =
    {
      pkgs,
      system,
      ...
    }:
    let
      inherit (self.packages.${system}) field;
      less = "${pkgs.less}/bin/less -r -F";
    in
    {
      packages = [
        field
        pkgs.chafa
        pkgs.comma
        pkgs.coreutils
        pkgs.ffmpeg
        pkgs.file
        pkgs.findutils
        pkgs.gum
        pkgs.jq
        pkgs.killall
        pkgs.magika-cli
        pkgs.perf
        pkgs.procps
        pkgs.xxd
        pkgs.yq
      ];

      environment = {
        sessionVariables = {
          # Pager settings
          LESS = "-r -F";
          DELTA_PAGER = less;
          PAGER = less;

          # Color settings
          GCC_COLORS = "error=1;31:warning=1;33:note=1;47;107:caret=1;47;107:locus=40;1;35:quote=1;33";
          GREP_COLORS = ":mt=1;36:ms=41;1;30:mc=1;41:sl=:cx=:fn=1;35;40:ln=32:bn=32:se=1;36;40";
        };

        shellAliases =
          let
            inherit (pkgs) coreutils findutils ffmpeg;
            wrap' = binPath: cmdline: "${binPath} ${cmdline}";
            wrap = binName: cmdline: wrap' (getExe' coreutils binName) cmdline;
          in
          {
            # Core utils aliases
            du = wrap "du" "-h";
            grep = wrap "grep" "--color";
            exe = wrap "chmod" "+x";
            x = getExe' findutils "xargs";
            ffmpeg = wrap' (getExe ffmpeg) "-hide_banner";

            # Cd aliases
            rd = "cd -";
            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";
            "....." = "cd ../../../..";

            sctl = "systemctl";
            uctl = "systemctl --user";
          };
      };
    };
}
