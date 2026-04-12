{ self, inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.fzf = inputs.wrappers.lib.wrapPackage (_: {
        inherit pkgs;
        package = pkgs.fzf;
        env = {
          FZF_DEFAULT_COMMAND = "${lib.getExe pkgs.fd} --type f --color=always";
          FZF_DEFAULT_OPTS = ''
            --border
            --ansi
            --layout=reverse
          '';
        };
      });
    };

  flake.modules.homeManager.base =
    { pkgs, lib, ... }:
    {
      programs.fzf = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.fzf;
        enableBashIntegration = true;
        enableFishIntegration = true;
        # enableNushellIntegration = true;
        enableZshIntegration = true;
        colors.bg = lib.mkForce "";
      };
    };
}
