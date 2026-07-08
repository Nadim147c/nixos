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
  perSystem = { pkgs, ... }: {
    packages.hyprland = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.hyprland;
      filesToExclude = [ "share/wayland-sessions/hyprland-uwsm.desktop" ];
      passthru.providedSessions = [ "hyprland" ];
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
    {
      systemd.user = {
        # ly -> hyprland-start -> exec-once hyprland-session.service -> startupServices
        # so the environment will be properly set
        targets.hyprland-session = {
          unitConfig = {
            Description = "Hyprland compositor session";
            BindsTo = [ "graphical-session.target" ];
            # start the other services here after the WM has already started (push vs pull)
            Wants = [ "graphical-session-pre.target" ];
            After = [ "graphical-session-pre.target" ];
          };
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
              equibop
              kitty
              qs-toggle
              dolphin
              mpvpaper-send-ipc
              ;
          in
          mkLuaObject {
            browser = getExe inputs.helium.packages.${system}.default;
            discord = getExe equibop;
            file_manager = getExe' dolphin "dolphin";
            hyprshutdown = getExe pkgs.hyprshutdown;
            mpvpaper_send_ipc = getExe mpvpaper-send-ipc;
            music = getExe pkgs.kopuz;
            playerctl = getExe' pkgs.playerctl "playerctl";
            qs_toggle = getExe qs-toggle;
            terminal = getExe kitty;
            wpctl = getExe' pkgs.wireplumber "wpctl";
          };
        displays = mkLuaObject <| mapAttrsToList createDisplayAttrs config.displays;
      };
    };
}
