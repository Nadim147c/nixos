{ config, lib, ... }:
let
  inherit (lib) toList;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      packages = toList pkgs.jujutsu;

      home.xdg.config.files."jj/config.toml".source = pkgs.writers.writeTOML "jj-config.toml" {
        user.name = config.fullname;
        user.email = config.email;
        ui.default-command = "log";
        ui.editor = "nvim";
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
