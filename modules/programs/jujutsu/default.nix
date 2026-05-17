{ config, self, ... }:
{
  flake.modules.homeManager.base =
    { lib, system, ... }:
    {
      programs.jujutsu = {
        enable = true;
        settings = {
          user.name = config.fullname;
          user.email = config.email;
          ui.default-command = "log";
          ui.edit = lib.getExe self.packages.${system}.neovim;
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
    };
}
