_: {
  flake.modules.homeManager.base =
    { config, pkgs, ... }:
    {
      home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";
      programs.starship = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        enableZshIntegration = true;
        settings = {
          add_newline = false;

          format = "$os$hostname$shell$directory( [\\[](red bold)$git_branch$hg_branch([:](green)$git_state$git_status)[\\]](red bold))$nix_shell$sudo$character";

          continuation_prompt = "[  => ](green bold)";

          character = {
            success_symbol = "[ 󰁔](green bold)";
            error_symbol = "[ 󰁔](red bold)";
            vimcmd_symbol = "[ ](blue bold)";
            vimcmd_replace_one_symbol = "[ /](yellow bold)";
            vimcmd_replace_symbol = "[ /](yellow bold)";
            vimcmd_visual_symbol = "[ |](green bold)";
          };

          os = {
            format = "$symbol";
            disabled = false;
            symbols = {
              Arch = "[ ](#1793d1)";
              NixOS = "[ ](#F2F8FD)";
              Kali = "[ ](#EEEEEE)";
              Windows = "[ ](#0078D4)";
            };
          };

          hostname = {
            format = "[\\($hostname\\)]($style) ";
            style = "yellow";
          };

          nix_shell = {
            disabled = false;
            format = " $state[( ($name))](bold blue)";
            impure_msg = "[](bold red)";
            pure_msg = "[](bold green)";
            unknown_msg = "[](bold yellow)";
          };

          shell = {
            format = "$indicator";
            fish_indicator = "[󰈺](#4EAD4E)";
            powershell_indicator = "󰨊";
            bash_indicator = "[](#FCFBFB)";
            cmd_indicator = "";
            zsh_indicator = "[Z](bold)";
            nu_indicator = "[󰟆](#4E950B)";
            unknown_indicator = "$";
            disabled = false;
          };

          directory = {
            format = " [$path]($style)[$read_only]($read_only_style)";
            read_only_style = "red";
            style = "cyan bold";
            read_only = "  ";
            home_symbol = " ~";
            truncation_length = 2;
            truncate_to_repo = false;
            truncation_symbol = "…/";
          };

          sudo = {
            format = "[$symbol]($style)";
            style = "bold yellow";
            symbol = " 󱐋";
            disabled = true;
          };

          git_branch = {
            format = "[$symbol$branch(:$remote_branch)]($style)";
            symbol = "";
            style = "red";
          };

          hg_branch = {
            format = "[ $symbol$branch ]($style)";
            symbol = " ";
          };

          git_state.format = "([$state\\(($progress_current/$progress_total)\\)]($style))";

          git_status = {
            format = "($conflicted$staged$modified$deleted$renamed$untracked$stashed)($ahead_behind)";
            conflicted = "[ !$count! ](red bold)";
            ahead = "[↑\${count}](yellow bold)";
            behind = "[↓\${count}](yellow bold)";
            diverged = "[↑\${ahead_count}↓\${behind_count}](yellow bold)";
            untracked = "[!$count](cyan bold)";
            stashed = "[~$count](bold blue bold)";
            modified = "[+$count](yellow bold)";
            staged = "[+$count](green bold)";
            renamed = "[>$count](green bold)";
            deleted = "[-$count](red bold)";
          };
        };
      };

    };
}
