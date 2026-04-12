{ self, inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.btop = inputs.wrappers.wrappers.btop.wrap (_: {
        inherit pkgs;
        package = pkgs.btop;
        settings = {
          theme_background = false;
          vim_keys = true;
          update_ms = 200;
        };
      });
    };

  flake.modules.homeManager.base =
    { system, ... }:
    {
      home.packages = [ self.packages.${system}.btop ];
    };
}
