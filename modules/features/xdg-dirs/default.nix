_: {
  flake.modules.nixos.base = { };
  flake.modules.homeManager.base =
    { config, ... }:
    let
      download = "${config.home.homeDirectory}/downloads";
      projects = "${config.home.homeDirectory}/git";
      media = category: "${config.home.homeDirectory}/media/${category}";
      files = category: "${config.home.homeDirectory}/files/${category}";
    in
    {
      home.preferXdgDirectories = true;

      xdg = {
        enable = true;
        userDirs = {
          inherit
            download
            projects
            ;
          enable = true;
          setSessionVariables = true;
          createDirectories = true;
          desktop = files "desktop";
          documents = files "documents";
          music = media "music";
          pictures = media "pictures";
          publicShare = files "public-share";
          templates = files "templates";
          videos = media "videos";
        };

        autostart = {
          enable = true;
          readOnly = true;
        };
      };

      home.sessionVariables = with config.xdg.userDirs; {
        XDG_CONFIG_HOME = config.xdg.configHome;
        XDG_DATA_HOME = config.xdg.dataHome;
        XDG_CACHE_HOME = config.xdg.cacheHome;
        XDG_STATE_HOME = config.xdg.stateHome;

        XDG_DESKTOP_DIR = desktop;
        XDG_DOCUMENTS_DIR = documents;
        XDG_DOWNLOAD_DIR = download;
        XDG_MUSIC_DIR = music;
        XDG_PICTURES_DIR = pictures;
        XDG_PROJECTS_DIR = projects;
        XDG_PUBLICSHARE_DIR = publicShare;
        XDG_TEMPLATES_DIR = templates;
        XDG_VIDEOS_DIR = videos;
      };
    };
}
