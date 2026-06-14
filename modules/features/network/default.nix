{
  flake.modules.nixos.base = {
    networking = {
      nameservers = [
        "127.0.0.1"
        "::1"
      ];
      networkmanager = {
        enable = true;
        dns = "none";
      };
    };

    services.dnscrypt-proxy = {
      enable = true;
      # Settings reference:
      # https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
      settings = {
        ipv6_servers = true;
        ipv4_servers = true;
        dnscrypt_servers = true;
        doh_servers = true;
        require_dnssec = true;
        bootstrap_resolvers = [
          "9.9.9.9:53"
          "8.8.8.8:53"
        ];
        ignore_system_dns = true;
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };
        server_names = [
          "quad9"
          "cloudflare"
        ];
      };
    };
  };
}
