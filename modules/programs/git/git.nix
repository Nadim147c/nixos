{ config, ... }:
let
  inherit (config) fullname email;
in
{
  flake.modules.nixos.base =
    { pkgs, lib, ... }:
    let
      inherit (lib) getExe;
      git-svu = pkgs.runCommandLocal "git-svu" { } ''
        mkdir -p $out/bin
        ln -s ${getExe pkgs.svu} $out/bin/git-svu
      '';

      cmd = pkg: text: "!${getExe pkg} ${text}";
    in
    {
      packages = with pkgs; [
        git-cliff
        git-extras
        git-svu
        svu
        gh
      ];

      programs.git = {
        enable = true;
        config = {
          user.name = fullname;
          user.email = email;

          alias = {
            grep = cmd pkgs.ripgrep "--color=always --hidden --glob=!.git";
            fork = cmd pkgs.gh "repo fork";
            find = cmd pkgs.fd "--hidden --exclude=.git";
            acm = "!git add -A && git commit";
            open = "browse";

            st = "status";
            co = "checkout";
            cm = "commit";
            aa = "add -A";
            hard = "reset --hard";
            amend = "commit --amend";
            fast-clone = "clone --depth=1";
            down = "pull --rebase";
            dis = "diff --cached";

            lsignored = "ls-files . --ignored --exclude-standard --others";
            graph = "log --graph --all --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(blue)  %D%n   %C(bold)%C(green)%s%C(reset)'";
          };

          init.defaultBranch = "main";

          diff.external = getExe pkgs.difftastic;
          diff.tool = "difftastic";
          difftool.difftastic.cmd = /* bash */ ''${getExe pkgs.difftastic} "$LOCAL" "$REMOTE"'';

          core = {
            compression = 9;
            fsync = "none";
            whitespace = "error";
          };

          branch.sort = "-committerdate";
          tag.sort = "version:refname";

          merge.conflictstyle = "diff3";

          fetch.fsckObjects = true;
          receive.fsckObjects = true;
          transfer.fsckObjects = true;

          interactive.singlekey = true;

          pack = {
            threads = 0;
            windowMemory = "1g";
            packSizeLimit = "1g";
          };

          diff = {
            algorithm = "histogram";
            colorMoved = "default";
            context = 3;
            interHunkContext = 10;
            mnemonicPrefix = true;
            renames = "copies";
          };

          commit = {
            gpgSign = false;
            verbose = true;
          };

          log = {
            abbrevCommit = true;
            graphColors = "blue,yellow,cyan,magenta,green,red";
          };

          status = {
            branch = true;
            short = true;
            showStash = true;
            showUntrackedFiles = "all";
          };

          color = {
            ui = true;
            blame.highlightRecent = "black bold,1 year ago,white,1 month ago,default,7 days ago,blue";

            branch = {
              current = "magenta";
              local = "default";
              remote = "yellow";
              upstream = "green";
              plain = "blue";
            };

            diff = {
              meta = "black bold";
              frag = "magenta";
              context = "white";
              whitespace = "yellow reverse";
              old = "red";
            };

            decorate = {
              HEAD = "red";
              branch = "blue";
              tag = "yellow";
              remoteBranch = "magenta";
            };
          };

          push = {
            autoSetupRemote = true;
            default = "current";
            followTags = true;
            gpgSign = false;
          };

          fetch.prune = true;

          rerere = {
            enabled = true;
            autoupdate = true;
          };

          rebase = {
            autoSquash = true;
            autoStash = true;
            updateRefs = true;
            missingCommitsCheck = "warn";
          };

          url = {
            "git@github.com:Nadim147c/".insteadOf = "me:";
            "git@gitlab.com:Nadim147c/".insteadOf = "gl-me:";
            "git@github.com:".insteadOf = "gh:";
            "git@gitlab.com:".insteadOf = "gh:";
            "ssh://aur@aur.archlinux.org/".insteadOf = "aur:";
          };

          help.autocorrect = "prompt";
          pull.rebase = true;
          submodule.fetchJobs = 16;

          "git-extras".feature.prefix = "feat";
        };
      };
    };
}
