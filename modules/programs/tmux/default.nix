{
  self,
  lib,
  inputs,
  ...
}:
let
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
in
{
  perSystem =
    { pkgs, self', ... }:
    let
      inherit (self'.packages) tmux-navigate tmux-sessionizer;
      navigate = getExe tmux-navigate;
      session = getExe tmux-sessionizer;
    in
    {
      packages.tmux = inputs.wrappers.wrappers.tmux.wrap {
        inherit pkgs;
        package = pkgs.tmux;
        baseIndex = 1;
        historyLimit = 10000;
        modeKeys = "vi";
        mouse = true;
        prefix = "C-o";
        sourceSensible = true;
        terminal = "xterm-256color";
        plugins = singleton pkgs.tmuxPlugins.better-mouse-mode;
        disableConfirmationPrompt = true;
        configAfter = /* tmux */ ''
          # Smart Alt+h/l navigation
          bind -n M-h run-shell "${navigate} h"
          bind -n M-j run-shell "${navigate} j"
          bind -n M-k run-shell "${navigate} k"
          bind -n M-l run-shell "${navigate} l"
          bind -n M-p run-shell "tmux neww ${session}"

          bind -n M-, run-shell "tmux swap-window -t -1 && tmux select-window -t -1"
          bind -n M-. run-shell "tmux swap-window -t +1 && tmux select-window -t +1"

          # Alt+n creates a new window
          bind -n M-n new-window

          set -g status-position top
          set -g status-justify absolute-centre
          set -g status-right ""
          set -g status-left "#S"
          set -g status-left-length 100
          set -sg escape-time 10

          set -g popup-border-lines "rounded"
          set -as terminal-features ",*:hyperlinks"
          set -g status-style "bg=default,fg=default"
          set -g window-status-current-style "bg=default,fg=green"
        '';
      };
    };

  flake.modules.nixos.base = { system, ... }: {
    preserveHome.directories = singleton ".local/share/tmux-list-repo";

    packages = singleton self.packages.${system}.tmux;

    programs.fish.interactiveShellInit = /* fish */ ''
      for mode in default insert visual normal
          bind -M $mode \ep ${getExe self.packages.${system}.tmux-sessionizer}
      end
    '';
  };
}
