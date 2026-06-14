{ lib, ... }:
{
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    {
      programs.zsh = {
        enable = true;
        histFile = "${config.home.xdg.data.directory}/zsh/history";
        enableCompletion = true;
        histSize = 100000;
        shellInit =
          let
            inherit (lib) flatten mkAfter;
            inherit (lib.strings) join;
            inherit (lib.filesystem) listFilesRecursive;
            check = p: (builtins.match ".*\\.plugin\\.zsh" p) != null;
            # recusivily find *.plugin.zsh file to source theme!
            pluginFiles =
              [
                pkgs.zsh-fzf-tab
                pkgs.zsh-fast-syntax-highlighting
                pkgs.zsh-autosuggestions
              ]
              |> map listFilesRecursive
              |> flatten
              |> builtins.filter check
              |> map (p: "source ${p}")
              |> join "\n";
          in
          mkAfter /* bash */ ''
            ${pluginFiles}

            zstyle ':completion:*:git-checkout:*' sort false
            zstyle ':completion:*:descriptions' format '[%d]'
            zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
            zstyle ':completion:*' menu no
            zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
            zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept --border=none
            zstyle ':fzf-tab:*' use-fzf-default-opts yes
            zstyle ':fzf-tab:*' switch-group '<' '>'
            zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
            zstyle ':fzf-tab:*' popup-min-size 80 12
          '';
      };
    };
}
