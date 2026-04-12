{
  perSystem =
    { pkgs, ... }:
    {
      packages.fork = pkgs.writeShellApplication {
        name = "fork";
        runtimeInputs = [ pkgs.uwsm ];
        text = ''
          if [ $# -eq 0 ]; then
              echo "Usage: fork <executable|entry.desktop[:action]> [args...]" >&2
              exit 1
          fi

          # Fork a new process that runs uwsm with the given args
          (setsid uwsm app -- "$@" >/dev/null 2>&1 & disown) &
          exit 0
        '';
      };
    };

}
