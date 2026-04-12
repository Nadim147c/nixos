{ config, lib, ... }:
let
  inherit (lib)
    filterAttrs
    flatten
    mapAttrsToList
    mkIf
    mkMerge
    mkOption
    optional
    types
    x
    ;
  inherit (types)
    attrs
    attrsOf
    functionTo
    submodule
    ;
in
{

  options.scripts = mkOption {
    type = attrsOf (submodule {
      options = {
        name = x.opt.line "";
        cond = x.opt.bool true;
        completion = x.opt.createOption attrs { };
        script = x.opt.createOption (functionTo types.package) (_: null);
      };
    });
  };

  config = {
    flake.modules.homeManager.base =
      { pkgs, ... }:
      let
        createCompletion = name: value: {
          "carapace/${name}.yaml" = {
            source = pkgs.writers.writeYAML "carapace.yaml" value.completion;
          };
        };
      in
      {
        home.packages =
          let
            getPackage = name: value: optional value.cond (value.script pkgs);
          in
          config.scripts |> mapAttrsToList getPackage |> flatten;

        xdg.configFile =
          config.scripts
          |> filterAttrs (_: value: value.completion != { })
          |> mapAttrsToList createCompletion
          |> mkMerge;
      };

    perSystem =
      { pkgs, ... }:
      let
        schema = pkgs.runCommand "carapace-schema.json" { nativeBuildInputs = [ pkgs.carapace ]; } ''
          carapace --schema > $out
        '';
        createCheck = name: script: {
          "scripts/${name}-completion" =
            pkgs.runCommand "${name}-validate-completion"
              {
                nativeBuildInputs = with pkgs; [ yajsv ];
                completion = pkgs.writers.writeYAML "carapace.yaml" script.completion;
                inherit schema;
              }
              ''
                yajsv -s $schema $completion
                touch $out
              '';
        };
      in
      {
        packages =
          config.scripts
          |> mapAttrsToList (name: value: { "${name}" = mkIf value.cond (value.script pkgs); })
          |> mkMerge;

        checks =
          config.scripts
          |> filterAttrs (_: value: value.completion != { })
          |> mapAttrsToList createCheck
          |> mkMerge;
      };
  };
}
