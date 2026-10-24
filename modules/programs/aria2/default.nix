{ self, ... }:
let
  settings = {
    allow-overwrite = true;
    allow-piece-length-change = true;
    always-resume = true;
    async-dns = false;
    auto-file-renaming = true;
    content-disposition-default-utf8 = true;
    continue = true;
    disk-cache = "64M";
    enable-rpc = false;
    file-allocation = "falloc";
    max-concurrent-downloads = 5;
    max-connection-per-server = 5;
    max-download-limit = 0;
    max-overall-download-limit = 0;
    min-split-size = "10M";
    no-file-allocation-limit = "8M";
    save-session-interval = 60;
    split = 10;
  };
in
{
  flake.wrappers.aria2 = { wlib, ... }: {
    imports = [ wlib.wrapperModules.aria2 ];
    inherit settings;
  };

  flake.tree.nixos.base.aria2 = { config, ... }: {
    imports = [ self.wrappers.aria2.install ];
    wrappers.aria2 = {
      enable = true;
      settings = settings // {
        dir = config.xdg-dirs.download;
        save-session = "${config.hj.xdg.state.directory}/aria2c/aria2c.session";
      };
    };
  };
}
