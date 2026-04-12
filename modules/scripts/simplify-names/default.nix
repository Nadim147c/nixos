{ lib, ... }:
let
  name = "simplify-names";
  sedExpression = lib.escapeShellArg ''
    s/[^a-z0-9]/-/g;
    s/-+/-/g;
    s/^-//;
    s/-$//;
    s/(.*)-/\1./
  '';

in
{
  scripts."${name}" = {
    completion = {
      inherit name;
      completion.positionalany = [ "$files" ];
    };
    script =
      pkgs:
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = with pkgs; [ gum ];
        text = ''
          if [[ $# -lt 1 ]]; then
              echo "${name}: please provide a input"
              exit 1
          fi

          for NAME in "$@"; do
              GENERATED=$(echo -n "$NAME" | tr '[:upper:]' '[:lower:]' | sed -E ${sedExpression})

              if [[ "$NAME" == "$GENERATED" ]]; then
                  continue
              fi

              NEW=$(gum input --header="$(printf "Rename: %q" "$NAME")" --prompt="New Name: " --value="$GENERATED")

              if [[ -z "$NEW" ]]; then
                  continue
              fi

              mv -v "$NAME" "$NEW"
          done
        '';
      };
  };
}
