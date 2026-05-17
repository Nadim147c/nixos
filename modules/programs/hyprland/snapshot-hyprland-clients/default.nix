let
  name = "snapshot-hyprland-clients";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      completion.positional = [
        [ "$files" ]
        [ "$files" ]
      ];
    };
    script =
      pkgs:
      pkgs.writeShellScriptBin "snapshot-hyprland-clients" ''
        ${pkgs.hyprland}/bin/hyprctl clients -j > /tmp/hyprland-clients.json
        ${pkgs.hyprland}/bin/hyprctl layers -j > /tmp/hyprland-layers.json
      '';
  };
}
