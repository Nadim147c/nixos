{
  self,
  lib,
  inputs,
  ...
}:
{

  perSystem =
    { pkgs, self', ... }:
    let
      navigate = lib.getExe self'.packages.tmux-navigate;
      session = lib.getExe self'.packages.tmux-sessionizer;
    in
    {
      packages.tmux = inputs.wrappers.wrappers.tmux.wrap (_: {
        inherit pkgs;
        package = pkgs.tmux;
        baseIndex = 1;
        historyLimit = 10000;
        modeKeys = "vi";
        mouse = true;
        prefix = "C-o";
        sourceSensible = true;
        terminal = "xterm-256color";
        plugins = [ pkgs.tmuxPlugins.better-mouse-mode ];
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
        '';
      });
    };

  flake.modules.homeManager.base =
    {
      config,
      system,
      ...
    }:
    let

      session = lib.getExe self.packages.${system}.tmux-sessionizer;
      reloadConfig = /* bash */ ''
        tmux source-file ${config.xdg.configHome}/tmux/tmux.conf || true
      '';
    in
    {
      home.packages = [ self.packages.${system}.tmux ];
      xdg.configFile."tmux/tmux.conf".text = /* tmux */ ''
        source ${config.xdg.configHome}/tmux/colors.conf
        set -g popup-border-style "fg=#{@rong_outline}"
        set -g status-style "bg=default,fg=#{@rong_on_background}"
        set -g window-status-current-style "bg=default,fg=#{@rong_color_2}"
      '';
      programs = {
        rong.settings.themes = lib.toList {
          target = "colors.tmux";
          links = "${config.xdg.configHome}/tmux/colors.conf";
          cmds = reloadConfig;
        };

        fish.interactiveShellInit = /* fish */ ''
          for mode in default insert visual normal
              bind -M $mode \ep ${session}
          end
        '';
      };
    };
}
