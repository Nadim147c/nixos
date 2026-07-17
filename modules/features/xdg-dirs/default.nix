{ config, lib, ... }:
let
  inherit (builtins) attrValues;
  inherit (config) username;
  inherit (lib) mapAttrs;
  inherit (lib.generators) toKeyValue;
  inherit (lib.x) quote;
in
{
  flake.modules.nixos.base =
    { config, ... }:
    let
      download = "${config.home.directory}/downloads";
      projects = "${config.home.directory}/git";
      media = category: "${config.home.directory}/media/${category}";
      files = category: "${config.home.directory}/files/${category}";
      dirs = {
        XDG_DESKTOP_DIR = files "desktop";
        XDG_DOCUMENTS_DIR = files "documents";
        XDG_DOWNLOAD_DIR = download;
        XDG_MUSIC_DIR = media "music";
        XDG_PICTURES_DIR = media "pictures";
        XDG_PROJECTS_DIR = projects;
        XDG_PUBLICSHARE_DIR = files "public-share";
        XDG_TEMPLATES_DIR = files "templates";
        XDG_VIDEOS_DIR = media "videos";
      };

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
      preserveHome.directories = [
        "files"
        "music"
        projects
      ];

      # Create directories automatically using systemd-tmpfiles on rebuild/boot
      systemd.tmpfiles.rules = allDirs |> map (dir: "d ${dir} 0755 ${username} users -");

      home.xdg.data.files."user-places.xbel".value.bookmarks = [
        {
          name = "home";
          icon = "folder-home";
          path = config.home.directory;
        }
        {
          name = "downloads";
          icon = "folder-downloads";
          path = dirs.XDG_DOWNLOAD_DIR;
        }
        {
          name = "projects";
          path = dirs.XDG_PROJECTS_DIR;
        }
        {
          name = "torrents";
          path = extra.torrents;
        }
        {
          name = "audios";
          icon = "folder-music";
          path = dirs.XDG_MUSIC_DIR;
        }
        {
          name = "private-audios";
          icon = "folder-music";
          path = extra.private-audios;
        }
        {
          name = "videos";
          icon = "folder-videos";
          path = dirs.XDG_VIDEOS_DIR;
        }
        {
          name = "private-videos";
          icon = "folder-videos";
          path = extra.private-videos;
        }
        {
          name = "pictures";
          icon = "folder-pictures";
          path = dirs.XDG_PICTURES_DIR;
        }
        {
          name = "private-pictures";
          icon = "folder-pictures";
          path = extra.private-pictures;
        }
        {
          name = "desktop";
          path = dirs.XDG_DESKTOP_DIR;
        }
      ];

      home.xdg.config.files."user-dirs.dirs" = {
        generator = value: toKeyValue { } (mapAttrs (_: quote) value);
        value = dirs;
      };

      sessionVariables = dirs // {
        XDG_CONFIG_HOME = config.home.xdg.config.directory;
        XDG_DATA_HOME = config.home.xdg.data.directory;
        XDG_CACHE_HOME = config.home.xdg.cache.directory;
        XDG_STATE_HOME = config.home.xdg.state.directory;
      };
    };
}
