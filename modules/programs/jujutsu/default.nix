{ config, lib, ... }:
let
  inherit (lib.generators) toJSON;
  inherit (config) username fullname email;
  inherit (lib) getExe singleton;
in
{
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    {
      packages = with pkgs; [
        jujutsu
        watchman
      ];
      # Should we???
      preserveHome.directories = singleton ".config/jj/repos";

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
          watchman.register-snapshot-trigger = true;
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
