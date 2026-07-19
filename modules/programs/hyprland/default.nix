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
    singleton
    ;
  inherit (lib.generators) toLua;
in
{
  perSystem = { pkgs, ... }: {
    packages.hyprland = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.hyprland;
      filesToExclude = singleton "share/wayland-sessions/hyprland-uwsm.desktop";
      passthru.providedSessions = singleton "hyprland";
    };
  };

  flake.modules.nixos.gui =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      mkType = _type: content: { inherit _type content; };
      mkImport = mkType "import";
      mkLuaObject = mkType "object";

      createConfig = mapAttrs' (
        name: value:
        let
          filename = "hypr/${name}.lua";
        in
        if value._type == "import" then
          nameValuePair filename { source = value.content; }
        else if value._type == "object" then
          nameValuePair filename { text = "return ${toLua { } value.content}"; }
        else
          throw "Unsupported format: ${value._type}"
      );

      createActiveDisplay =
        output: display:
        let
          inherit (display)
            width
            height
            refreshRate
            x
            y
            ;
        in
        {
          inherit output;
          mode = "${toString width}x${toString height}@${toString refreshRate}";
          position = "${toString x}x${toString y}";
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
    {
      systemd.user.targets.hyprland-session = {
        unitConfig = {
          Description = "Hyprland compositor session";
          BindsTo = singleton "graphical-session.target";
          # start the other services here after the WM has already started (push vs pull)
          Wants = singleton "graphical-session-pre.target";
          After = singleton "graphical-session-pre.target";
        };
      };
      programs.hyprland = {
        enable = true;
        package = self.packages.${system}.hyprland;
        xwayland.enable = true;
        withUWSM = false;
      };

      packages = [
        pkgs.hyprshutdown
        pkgs.playerctl
        pkgs.wl-clipboard
      ];

      home.xdg.config.files = createConfig {
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
            inherit (self.packages.${system})
              dolphin
              equibop
              hyprscreenshot
              kitty
              kopuz
              mpvpaper-send-ipc
              qs-toggle
              ;
          in
          mkLuaObject {
            browser = getExe inputs.helium.packages.${system}.default;
            discord = getExe equibop;
            file_manager = getExe' dolphin "dolphin";
            hyprscreenshot = getExe hyprscreenshot;
            hyprshutdown = getExe pkgs.hyprshutdown;
            mpvpaper_send_ipc = getExe mpvpaper-send-ipc;
            music = getExe kopuz;
            playerctl = getExe' pkgs.playerctl "playerctl";
            qs_toggle = getExe qs-toggle;
            terminal = getExe kitty;
            wpctl = getExe' pkgs.wireplumber "wpctl";
          };
        displays = mkLuaObject <| mapAttrsToList createDisplayAttrs config.displays;
      };
    };
}
