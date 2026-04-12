let
  name = "qs-tmux-session-info";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [ tmux ];
        source = ./qs-tmux-session-info.nu;
      };
  };
}
