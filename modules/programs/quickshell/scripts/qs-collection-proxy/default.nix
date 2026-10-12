let
  name = "qs-collection-proxy";
in
{
  scripts."${name}" = {
    inherit name;
    script =
      pkgs:
      pkgs.writeNuApplication {
        inherit name;
        runtimeInputs = with pkgs; [
          coreutils
          xxhash
        ];
        source = ./qs-collection-proxy.nu;
      };
  };
}
