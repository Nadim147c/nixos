{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib)
    getExe
    getExe'
    mapAttrs'
    mapAttrsToList
    nameValuePair
    ;
  inherit (lib.generators) toLua;
in
{

  flake.modules.nixos.gui = {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
  };

  flake.modules.homeManager.gui =
    {
      osConfig,
      pkgs,
      system,
      lib,
      ...
    }:
    {
      services.hyprpolkitagent.enable = true;

      home.activation.reloadHyprland = lib.hm.dag.entryAfter [ "writeBoundary" ] /* bash */ ''
        ${getExe' pkgs.hyprland "hyprctl"} --instance 0 reload
      '';

      home.packages = with pkgs; [
        playerctl
        wl-clipboard
      ];

      xdg.configFile =
        let
          mkImport = source: {
            _type = "import";
            inherit source;
          };
          mkLuaObject = attrs: {
            _type = "object";
            text = ''
              return ${toLua { } attrs}
            '';
          };

          createConfig =
            attrs:
            mapAttrs' (
              name: value:
              let
                filename = "hypr/${name}.lua";
              in
              if value._type == "import" then
                nameValuePair filename { inherit (value) source; }
              else
                nameValuePair filename { inherit (value) text; }
            ) attrs;
        in
        createConfig {
          animations = mkImport ./animations.lua;
          hyprland = mkImport ./hyprland.lua;
          envs = mkLuaObject {
            CLUTTER_BACKEND = "wayland";
            SDL_VIDEODRIVER = "wayland";
            XDG_CURRENT_DESKTOP = "Hyprland";
            XDG_SESSION_DESKTOP = "Hyprland";
            XDG_SESSION_TYPE = "wayland";
            GDK_BACKEND = "wayland,x11,*";
          };
          programs =
            let
              uwsm = getExe pkgs.uwsm;
              getCommand =
                program:
                if builtins.isString program then
                  "${uwsm} app -- ${program}"
                else
                  "${uwsm} app -- ${getExe program}";
            in
            mkLuaObject {
              inherit uwsm;
              browser = getCommand inputs.helium.packages.${system}.default;
              discord = getCommand pkgs.equibop;
              file_manager = getCommand <| getExe' pkgs.kdePackages.dolphin "dolphin";
              hyprshutdown = getCommand pkgs.hyprshutdown;
              playerctl = getCommand <| getExe' pkgs.playerctl "playerctl";
              qs_toggle = getCommand self.packages.${system}.qs-toggle;
              terminal = getCommand pkgs.kitty;
              wpctl = getCommand <| getExe' pkgs.wireplumber "wpctl";
            };
          displays =
            let
              createActiveDisplay =
                output: display:
                {
                  inherit output;
                  mode = "${toString display.width}x${toString display.height}@${toString display.refreshRate}";
                  position = "${toString display.x}x${toString display.y}";
                }
                // display.extra;
              createDisabledDisplay = output: display: {
                inherit output;
                disabled = true;
              };
              createDisplayAttrs =
                name: value:
                if value.enable then createActiveDisplay name value else createDisabledDisplay name value;
            in
            mkLuaObject <| mapAttrsToList createDisplayAttrs osConfig.displays;
        };
    };
}
