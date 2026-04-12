let
  name = "xdg-base-dir";
in
{
  scripts."${name}" = {
    inherit name;
    completion = {
      inherit name;
      completion.positional = [
        [
          "bin-home"
          "cache-file"
          "cache-home"
          "config-dirs"
          "config-file"
          "config-home"
          "data-dirs"
          "data-file"
          "data-home"
          "font-dirs"
          "home"
          "runtime-dir"
          "runtime-file"
          "search-cache"
          "search-config"
          "search-config-dirs"
          "search-data"
          "search-data-dirs"
          "search-runtime"
          "search-state"
          "state-file"
          "state-home"
          "user-documents"
          "user-download"
          "user-music"
          "user-picture"
          "user-public"
          "user-templates"
          "user-videos"
        ]
      ];
    };
    script = pkgs: pkgs.writers.writeGoBin name (builtins.readFile ./xdg-base-dir.go);
  };
}
