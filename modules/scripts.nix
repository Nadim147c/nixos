{ config, lib, ... }:
let
  inherit (lib)
    const
    filterAttrs
    flatten
    mapAttrsToList
    mkIf
    mkMerge
    mkOption
    optional
    types
    ;
  inherit (lib.x) opt;
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
        name = opt.line "";
        cond = opt.createOption (functionTo types.bool) (const true);
        completion = opt.createOption attrs { };
        script = opt.createOption (functionTo types.package) (const null);
      };
    });
  };

  config = {
    flake.modules.nixos.base =
      { pkgs, ... }:
      {
        packages =
          config.scripts
          |> mapAttrsToList (name: value: optional (value.cond pkgs) (value.script pkgs))
          |> flatten;

        home.xdg.config.files =
          config.scripts
          |> filterAttrs (_: value: value.completion != { })
          |> mapAttrsToList (
            name: value: {
              "carapace/specs/${name}.yaml" = {
                generator = lib.generators.toYAML { };
                value = value.completion;
              };
            }
          )
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
          |> mapAttrsToList (name: value: { "${name}" = mkIf (value.cond pkgs) (value.script pkgs); })
          |> mkMerge;

        checks =
          config.scripts
          |> filterAttrs (_: value: value.completion != { })
          |> mapAttrsToList createCheck
          |> mkMerge;
      };
  };
}
