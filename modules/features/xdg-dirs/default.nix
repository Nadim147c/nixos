{ lib, ... }:
let
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
    in
    {
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
