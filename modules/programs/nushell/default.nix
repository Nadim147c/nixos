{ lib, nu-builtins, ... }:
let
  inherit (lib.hm.nushell) toNushell;
  inherit (lib.modules)
    mkIf
    mkMerge
    mkDefault
    mkAliasOptionModule
    ;
  inherit (lib.strings) concatMapAttrsStringSep;
  inherit (lib.attrsets) filterAttrs;
  inherit (builtins) fromJSON elem;
  inherit (lib.x) opt;

  notElem = x: l: !(elem x l);
  # nu --config /dev/null --env-config /dev/null -c 'help commands | where command_type == built-in | get name | each { split row " " | first }  | sort | uniq | to json --raw' | wl-copy
  nu-builtins = fromJSON ''["abbr","all","ansi","any","append","ast","attr","bits","bytes","cal","cd","char","chunk-by","chunks","clear","columns","combinations","commandline","compact","complete","config","cp","date","debug","decode","default","describe","detect","difference","do","drop","du","each","echo","encode","enumerate","error","every","exec","exit","explain","explore","fill","filter","find","first","flatten","format","from","generate","get","glob","grid","group-by","hash","headers","help","hide-env","histogram","history","http","idx","ignore","input","insert","inspect","interleave","intersect","into","is-admin","is-empty","is-not-empty","is-redirected","is-terminal","items","job","join","keybindings","kill","last","length","let-env","lines","load-env","ls","math","matrix","merge","metadata","mkdir","mktemp","move","mv","nu-check","nu-highlight","open","overlay","panic","par-each","parse","path","peek","permutations","plugin","port","prepend","print","ps","query","random","reduce","reject","rename","reverse","rm","roll","rotate","run-external","run-internal","save","schema","scope","select","semver","seq","shuffle","skip","sleep","slice","sort","sort-by","split","start","stor","str","sys","table","take","tee","term","timeit","to","touch","transpose","tutor","ulimit","umask","uname","union","uniq","uniq-by","unlet","update","upsert","url","values","version","view","watch","which","whoami","window","with-env","wrap","zip"]'';
in
{
  flake.tree.nixos.base.common =
    { config, pkgs, ... }:
    let
      inherit (config.environment) shellAliases;
      cfg = config.programs.nushell;

      makeSource = name: value: "source ${pkgs.mkInitScript "init-${name}.nu" value}";
      extraInit = concatMapAttrsStringSep "\n" makeSource cfg.init;
      alias =
        filterAttrs (name: _: notElem name nu-builtins) shellAliases
        |> concatMapAttrsStringSep "\n" (name: value: "alias ${name} = ${value}");
    in
    {
      imports = [
        (mkAliasOptionModule
          [ "programs" "nushell" "interactiveShellInit" ]
          [ "programs" "nushell" "extraConfig" ]
        )
      ];
      options.programs.nushell = {
        extraConfig = opt.block "";
        init = opt.attrs.block { };
        settings = opt.attrs.recursive {
          show_banner = false;
          edit_mode = "vi";
          cursor_shape = {
            vi_insert = "line";
            vi_normal = "block";
            emacs = "block";
          };
          history = {
            file_format = "sqlite";
            isolation = false;
            max_size = 5000000;
            sync_on_enter = true;
          };
        };
      };

      config = mkIf cfg.enable {
        packages = mkIf (cfg.package != null) [ cfg.package ];
        hj.xdg.config.files."nushell/config.nu".text = mkMerge [
          (mkIf (cfg.settings != { }) "$env.config = ${toNushell { } cfg.settings}")
          (mkIf (shellAliases != { }) alias)
          (mkIf (cfg.init != { }) extraInit)
          cfg.extraConfig
        ];
      };
    };

  flake.tree.nixos.base.nushell = {
    programs.nushell.enable = mkDefault true;
  };
}
