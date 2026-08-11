{ config, lib, ... }:
let
  inherit (config) username;
  inherit (builtins) attrValues;
  inherit (lib.attrsets) mapAttrs mapAttrs' nameValuePair;
  inherit (lib.generators) toKeyValue;
  inherit (lib.options) mkOption;
  inherit (lib.strings) toUpper;
  inherit (lib.trivial) const;
  inherit (lib.types) attrs;
  inherit (lib.x) quote;
in
{
  flake.modules.nixos.base =
    { config, ... }:
    let
      download = "${config.hj.directory}/downloads";
      projects = "${config.hj.directory}/git";
      media = category: "${config.hj.directory}/media/${category}";
      files = category: "${config.hj.directory}/files/${category}";
      dirs = {
        desktop = files "desktop";
        documents = files "documents";
        download = download;
        music = media "music";
        pictures = media "pictures";
        projects = projects;
        publicshare = files "public-share";
        templates = files "templates";
        videos = media "videos";
      };

      xdg = mapAttrs' (name: value: nameValuePair "XDG_${toUpper name}_DIR" value) dirs;

      # Even though flatpak supposed to be a sandbox. Most of it software
      # Default to xdg-pictures/video readonly. Which means potentially
      # untrusted software can read your private videos. Thus, it better
      # to not save private media in them.
      extra = {
        private-pictures = media "private-pictures";
        private-videos = media "private-videos";
        private-audios = media "private-audios";
        torrents = files "torrents";
      };
      allDirs = attrValues (dirs // extra);
    in
    {
      options.xdg-dirs = mkOption {
        type = attrs;
        default = dirs // extra;
        readOnly = true;
      };

      config = {
        preserveHome.directories = [
          "downloads"
          "files"
          "media"
          "git"
        ];

        # Create directories automatically using systemd-tmpfiles on rebuild/boot
        systemd.tmpfiles.rules = map (dir: "d ${dir} 0755 ${username} users -") allDirs;

        hj.xdg.data.files."user-places.xbel".value.bookmarks = [
          {
            name = "home";
            icon = "folder-home";
            path = config.hj.directory;
          }
          {
            name = "downloads";
            icon = "folder-downloads";
            path = dirs.download;
          }
          {
            name = "projects";
            path = dirs.projects;
          }
          {
            name = "torrents";
            path = extra.torrents;
          }
          {
            name = "audios";
            icon = "folder-music";
            path = dirs.music;
          }
          {
            name = "private-audios";
            icon = "folder-music";
            path = extra.private-audios;
          }
          {
            name = "videos";
            icon = "folder-videos";
            path = dirs.videos;
          }
          {
            name = "private-videos";
            icon = "folder-videos";
            path = extra.private-videos;
          }
          {
            name = "pictures";
            icon = "folder-pictures";
            path = dirs.pictures;
          }
          {
            name = "private-pictures";
            icon = "folder-pictures";
            path = extra.private-pictures;
          }
          {
            name = "desktop";
            path = dirs.desktop;
          }
          {
            name = "documents";
            hidden = true;
            path = dirs.documents;
          }
        ];

        hj.xdg.config.files."user-dirs.dirs" = {
          generator = value: toKeyValue { } (mapAttrs (const quote) value);
          value = xdg;
        };

        sessionVariables = xdg // {
          XDG_CONFIG_HOME = config.hj.xdg.config.directory;
          XDG_DATA_HOME = config.hj.xdg.data.directory;
          XDG_CACHE_HOME = config.hj.xdg.cache.directory;
          XDG_STATE_HOME = config.hj.xdg.state.directory;
        };
      };
    };
}
