{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
  inherit (lib.strings) makeBinPath;
in
{
  perSystem = { self', pkgs, ... }: {
    packages.batman = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.bat-extras.batman;
      prefixVar = singleton [
        "PATH"
        ":"
        (makeBinPath [ self'.packages.bat ])
      ];
    };

    packages.bat_plus = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      binName = "bat+";
      package = self'.packages.bat;
      filesToExclude = [ "bin/bat" ];
      appendFlag = [
        "--plain"
        "--color=always"
        "--pager="
      ];
    };

    packages.bat = inputs.wrappers.lib.wrapPackage (
      { config, ... }:
      let
        nuSystex = pkgs.fetchFromGitHub {
          owner = "kurokirasama";
          repo = "nushell_sublime_syntax";
          rev = "8a1bb9205859d0c2f362c6c5a2b7ef1a7a87c387";
          hash = "sha256-2A7c6/FOsOyzyGAshZJZvZ/m5w1cKj7uckB+pzdlr3M=";
        };
        enkiThemes = pkgs.fetchFromGitHub {
          owner = "enkia";
          repo = "enki-theme";
          rev = "0b629142733a27ba3a6a7d4eac04f81744bc714f";
          hash = "sha256-Q+sac7xBdLhjfCjmlvfQwGS6KUzt+2fu+crG4NdNr4w=";
        };
        configDir = "${placeholder "out"}/${config.binName}-config";
      in
      {
        inherit pkgs;
        package = pkgs.bat;
        env = {
          BAT_CONFIG_DIR = configDir;
          BAT_THEME = "Enki-Tokyo-Night";
        };
        buildCommand = {
          makeBatSyntaxes = ''
            mkdir -p ${configDir}/syntaxes
            ln -s ${nuSystex}/nushell.sublime-syntax ${configDir}/syntaxes/nushell.sublime-syntax
          '';
          makeBatThemes = ''
            mkdir -p ${configDir}/themes
            ln -s ${enkiThemes}/scheme/*.tmTheme ${configDir}/themes/
          '';
        };
      }
    );
  };

  flake.modules.nixos.base =
    { system, ... }:
    {
      environment.shellAliases.cat = getExe self.packages.${system}.bat;
      packages = with self.packages.${system}; [
        bat
        bat_plus
        batman
      ];
    };
}
