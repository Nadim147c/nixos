{ self, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.ripgrep = inputs.wrappers.lib.wrapPackage (
        { config, ... }:
        {
          inherit pkgs;
          package = pkgs.ripgrep;
          addFlag = [ "--hidden" ];
          flags."--ignore-file" = config.constructFiles.renderedSettings.path;
          flagSeparator = "=";
          constructFiles.renderedSettings = {
            relPath = "${config.binName}-ignore";
            content = ''
              .git/
              .jj/
              *.bak
            '';
          };
        }
      );
    };

  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.ripgrep ];
    };
}
