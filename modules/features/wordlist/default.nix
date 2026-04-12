{ config, ... }:
{
  flake.modules.nixos.hack =
    { pkgs, ... }:
    let
      dict = "${pkgs.scowl}/share/dict";
    in
    {
      environment.wordlist = {
        enable = true;
        lists = {
          WORDLIST = [ "${dict}/words.txt" ];
          AUGMENTED_WORDLIST = [
            "${dict}/words.txt"
            "${dict}/words.variants.txt"
          ];
        };
      };
      home.imports = [ config.flake.modules.homeManager.hack ];
    };

  flake.modules.homeManager.hack =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ scowl ];
    };
}
