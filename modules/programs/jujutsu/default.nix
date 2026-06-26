{ config, lib, ... }:
let
  inherit (lib) toList getExe;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      packages = toList pkgs.jujutsu;

      home.xdg.config.files."jj/config.toml".generator = pkgs.writers.writeTOML "jj-config.toml";
      home.xdg.config.files."jj/config.toml".value = {
        user.name = config.fullname;
        user.email = config.email;
        ui = {
          editor = "nvim";
          default-command = "log";
          diff-formatter = [
            (getExe pkgs.difftastic)
            "--color"
            "always"
            "$left"
            "$right"
          ];
        };
        signing = {
          behavior = "own";
          backend = "ssh";
          key = "~/.ssh/master.pub";
        };
        templates.draft_commit_description = /* js */ ''
          concat(
            description,
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.summary()),
            ),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\n",
            "JJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };
    };
}
