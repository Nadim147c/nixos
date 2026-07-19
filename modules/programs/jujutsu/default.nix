{ config, lib, ... }:
let
  inherit (config) fullname email;
  inherit (lib) getExe singleton;
in
{
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    {
      packages = singleton pkgs.jujutsu;
      # Should we???
      preserveHome.directories = singleton ".config/jj/repos";

      home.xdg.config.files."jj/config.toml".generator = pkgs.writers.writeTOML "jj-config.toml";
      home.xdg.config.files."jj/config.toml".value = {
        user.name = fullname;
        user.email = email;
        ui = {
          editor = "nvim";
          default-command = "log";
          diff-formatter = [
            (getExe pkgs.difftastic)
            "--color"
            "always"
            "$left"
            "$right"
          ];
        };
        signing = {
          behavior = "own";
          backend = "ssh";
          key = "~/.ssh/master.pub";
          # Use private key from non standard location!
          backends.ssh.program = pkgs.writeShellScript "jj-ssh-signer" ''
            if [[ "$1" == "-Y" && "$2" == "sign" ]]; then
                exec ${pkgs.openssh}/bin/ssh-keygen "$@" -f "${config.sops.secrets."ssh/master".path}"
            else
                exec ${pkgs.openssh}/bin/ssh-keygen "$@"
            fi
          '';
        };
        templates.draft_commit_description = /* js */ ''
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
    };
}
