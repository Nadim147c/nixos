{ lib, ... }:
{
  flake.modules.homeManager.base =
    { config, pkgs, ... }:
    {
      programs.zsh = {
        enable = true;
        enableCompletion = false;
        history.path = "${config.xdg.dataHome}/zsh/history";
        dotDir = "${config.xdg.configHome}/zsh";
        history.ignoreSpace = true;
        completionInit = "";
        initContent =
          let
            plugins = [
              pkgs.zsh-fzf-tab
              pkgs.zsh-fast-syntax-highlighting
              pkgs.zsh-autosuggestions
            ];

            # recusivily find *.plugin.zsh file to source theme!
            pluginFiles =
              let
                inherit (lib) flatten;
                find = lib.filesystem.listFilesRecursive;
                check = p: (builtins.match ".*\\.plugin\\.zsh" p) != null;
                join = lib.strings.join "\n";
              in
              plugins |> map find |> flatten |> builtins.filter check |> map (p: "source ${p}") |> join;
          in
          lib.mkAfter /* bash */ ''
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
