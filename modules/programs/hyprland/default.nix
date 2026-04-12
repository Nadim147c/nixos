{
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mapAttrsToList;
  createLua = lib.generators.toLua { };
in
{

  flake.modules.nixos.gui =
    { system, ... }:
    let
      inherit (inputs.hyprland.packages.${system}) hyprland xdg-desktop-portal-hyprland;
    in
    {
      imports = [ inputs.hyprland.nixosModules.default ];
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        package = hyprland;
        portalPackage = xdg-desktop-portal-hyprland;
        withUWSM = true;
      };
    };

  flake.modules.homeManager.gui =
    {
      osConfig,
      config,
      pkgs,
      ...
    }:
    let
      inherit (lib) getExe getExe' nameValuePair;
      createHyprlandConfig =
        modules:
        modules
        |> map (source: nameValuePair "hypr/${baseNameOf source}" { inherit source; })
        |> builtins.listToAttrs;
    in
    {
      services.hyprpolkitagent.enable = true;

      xdg.configFile =
        createHyprlandConfig [
          ./animations.lua
          ./hyprland.lua
        ]
        // {
          "hypr/envs.lua".text = ''
            return ${
              createLua {
                CLUTTER_BACKEND = "wayland";
                SDL_VIDEODRIVER = "wayland";
                XDG_CURRENT_DESKTOP = "Hyprland";
                XDG_SESSION_DESKTOP = "Hyprland";
                XDG_SESSION_TYPE = "wayland";
                GDK_BACKEND = "wayland,x11,*";
              }
            }
          '';
          "hypr/programs.lua".text = ''
            return ${
              createLua {
                terminal = getExe pkgs.kitty;
                file_manager = getExe' pkgs.kdePackages.dolphin "dolphin";
                browser = getExe config.programs.zen-browser.package;
                discord = getExe pkgs.equibop;
              }
            }
          '';
          "hypr/displays.lua".text =
            let
              createDisplayAttrs =
                name: display:
                if display.enable then
                  {
                    output = name;
                    mode = "${toString display.width}x${toString display.height}@${toString display.refreshRate}";
                    position = "${toString display.x}x${toString display.y}";
                  }
                  // display.extra
                else
                  {
                    output = name;
                    disabled = true;
                  };
            in
            "return ${osConfig.displays |> mapAttrsToList createDisplayAttrs |> createLua}";

        };
    };
}
