{ self, inputs, ... }:
{

  perSystem =
    { pkgs, ... }:
    {
      packages.fastfetch = inputs.wrappers.wrappers.fastfetch.wrap (_: {
        inherit pkgs;
        package = pkgs.fastfetch;
        settings = {
          logo.type = "small";
          display.separator = " : ";
          modules = [
            {
              type = "title";
              key = "  SYS";
              format = "{2}";
              keyColor = "red";
            }
            {
              type = "os";
              key = "  OS ";
              keyColor = "green";
            }
            {
              type = "kernel";
              key = "  KER";
              keyColor = "yellow";
            }
            {
              type = "shell";
              key = "  SH ";
              keyColor = "blue";
            }
            {
              type = "terminal";
              key = "  TRM";
              keyColor = "magenta";
            }
            { type = "colors"; }
          ];
        };
      });
    };

  flake.modules.homeManager.base =
    { system, ... }:
    {
      home.packages = [ self.packages.${system}.fastfetch ];
    };
}
