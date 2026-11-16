{ config, lib, ... }:
let
  inherit (lib.generators) toJSON;
  inherit (lib.lists) singleton;
  inherit (lib.meta) getExe;
  inherit (config) username fullname email;
in
{
  flake.tree.nixos.base.jujutsu =
    { config, pkgs, ... }:
    {
      packages = singleton pkgs.jujutsu;

      hj.xdg.config.files."jj/config.toml".generator = pkgs.writers.writeTOML "jujutsu.toml";
      hj.xdg.config.files."jj/config.toml".value = {
        user.name = fullname;
        user.email = email;

        ui = {
          editor = "nvim";
          default-command = "log";
          diff-editor = ":builtin";
          diff-formatter = [
            (getExe pkgs.delta)
            "--width=$width"
            "$left"
            "$right"
          ];
        };

        signing = {
          behavior = "own";
          backend = "ssh";
          key = "~/.ssh/master.pub";
          # Use private key from nonstandard location!
          backends.ssh.program = pkgs.writeShellScript "jj-ssh-signer" ''
            if [[ "$1" == "-Y" && "$2" == "sign" ]]; then
                exec ${pkgs.openssh}/bin/ssh-keygen "$@" -f "${config.sops.secrets."ssh/master".path}"
            else
                exec ${pkgs.openssh}/bin/ssh-keygen "$@"
            fi
          '';
        };

        # Copied from https://github.com/RGBCube/ncc/blob/60d98caa4cb2a273619385120b51008bb959234b/modules/version-control/version-control.mod.nix
        fsmonitor = {
          backend = "watchman";
          watchman.register-snapshot-trigger = false;
        };

        templates.git_push_bookmark = /* javascript */ ''
          "${username}/change-" ++ change_id.short()
        '';

        templates.draft_commit_description = /* javascript */ ''
          concat(
            description,
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.summary()),
            ),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            surround(
              "\nJJ: This commit message generator:\n", "",
              indent("JJ:     ", ${builtins.toJSON ''
                Generate a concise, factual git commit message for the provided diff.

                Formatting Rules
                - **Format:** `<scope>: <concise summary of the change>`
                - **Scope:** Use the primary path or subsystem affected (e.g., `programs/quickshell`, `features/flatpak`, `hosts/chronoshift`, `pkgs/morphe-desktop`, `scripts/ffcompress`, `nix`, `flake`, `treewide`). Use brace expansion when touching multiple related items in the same parent directory (e.g., `programs/{navidrome,slskd,qbittorrent}`).
                - **Summary:** Use lowercase imperative/present-tense phrasing (e.g., `add ...`, `update ...`, `remove ...`, `disable ...`, `fix ...`, `use ...`). Keep it brief and direct—typically under 60–70 characters.
                - **Output only:** Return only the commit message, with no markdown fences or extra explanation.

                ### Examples of Target Style
                - `nix/dev-shells: use system quickshell for quickshell-dev script`
                - `programs/quickshell: shader update`
                - `programs/neovim: disable harper lsp`
                - `programs/{navidrome,slskd,qbittorrent}: update servers icons`
                - `pkgs/morphe-desktop: update 1.18.0 -> 1.19.0`
                - `programs/git: replace git-copy.go with git-copy.nu`
                - `treewide: implement dendritic pattern`
                - `features/flatpak: uninstall Unmanaged `
                - `programs/hyprland: fix screen off after sleep`
              ''}),
            ),
            "\n",
            "JJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };

      hj.xdg.config.files."watchman/watchman.json" = {
        generator = toJSON { };
        value = {
          ignore_dirs = [
            ".direnv"
            "node_modules"
            "target"
          ];
        };
      };
    };
}
