{
  flake.modules.nixos.base =
    { config, pkgs, ... }:
    {
      services.qbittorrent = {
        user = config.username;
        group = config.username;
        webuiPort = 1616;
        # Allow remove devices control qbittorrent
        openFirewall = true;
        serverConfig = {
          LegalNotice.Accepted = true;
          Preferences = {
            Downloads.SavePath = "${config.home.home.homeDirectory}/files/torrents";
            WebUI = {
              AlternativeUIEnabled = true;
              RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
              AuthSubnetWhitelist = "192.168.1.0/24";
              AuthSubnetWhitelistEnabled = true;
              LocalHostAuth = false;
            };
          };
        };
      };
    };
}
