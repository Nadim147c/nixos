{ lib, ... }:
let
  inherit (lib.lists) flatten singleton;
  inherit (lib.modules) mkAfter;
  inherit (lib.strings) join concatMapAttrsStringSep;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.x) opt;
in
{
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    let
      makeSource = name: value: "source ${pkgs.mkInitScript "init-${name}.zsh" value}";
      extraInit = concatMapAttrsStringSep "\n" makeSource config.programs.zsh.init;

      isPluginZSH = p: (builtins.match ".*\\.plugin\\.zsh" p) != null;
      # recusivily find *.plugin.zsh file to source theme!
      pluginFiles =
        [
          pkgs.zsh-fzf-tab
          pkgs.zsh-fast-syntax-highlighting
          pkgs.zsh-autosuggestions
        ]
        |> map listFilesRecursive
        |> flatten
        |> builtins.filter isPluginZSH
        |> map (p: "source ${p}")
        |> join "\n";
    in
    {
      options.programs.zsh.init = opt.attrs.block { };

      config = {
        preserveHome.directories = singleton ".local/share/zsh";
        environment.pathsToLink = singleton "/share/zsh";
      };
      config.programs.zsh = {
        enable = true;
        histFile = "${config.hj.xdg.data.directory}/zsh/history";
        enableCompletion = true;
        histSize = 100000;
        interactiveShellInit = mkAfter /* bash */ ''
          ${extraInit}

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
