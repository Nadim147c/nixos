{ inputs, lib, ... }:
let
  inherit (lib.x) genMimes;
  inherit (lib)
    fix
    singleton
    concatStringsSep
    mapAttrsToList
    escapeURL
    ;
in
{
  perSystem = { system, ... }: {
    packages.helium = inputs.helium.packages.${system}.default;
  };

  flake.modules.nixos.gui =
    { pkgs, system, ... }:
    let
      chromiumUpdateTheme = pkgs.writers.writeNu "chromium-update-theme" /* nu */ ''
        def main [settings_file: string] {
          let input_path = "/tmp/chromium.json"

          let settings = open $settings_file
          let theme = open $input_path

          let color = $theme.BrowserThemeColor? | default ""
          if not ($color =~ "^#[0-9a-fA-F]{6}$") {
            print --stderr "BrowserThemeColor key is missor or not a valid color from input JSON."
            exit 1
          }

          $settings
          | upsert BrowserThemeColor $color
          | collect
          | save --force "/etc/chromium/policies/managed/policies.json"
        }
      '';

      # Copied from https://github.com/RGBCube/ncc/blob/fd1860d09aaca345badff5f48b38c124b729fdf8/modules/web-browser.mod.nix
      settings =
        pkgs.writers.writeJSON "chromium-policy.json"
        <| fix (final: {
          # EXTENSIONS
          ExtensionInstallBlocklist = singleton "*";
          ExtensionInstallAllowlist = final.ExtensionInstallForcelist;
          ExtensionInstallForcelist = [
            "jinjaccalgkegednnccohejagnlnfdag" # Violentmonkey
            "lodbfhdipoipcjmlebjbgmmgekckhpfb" # Harper
            "effdbpeggelllpfkjppbokhmmiinhlmg" # BetterLyrics
            "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
            "enamippconapkdmgfgjchkhakpfinmaj" # DeArrow
            "blockjmkbacgjkknlgpkjjiijinjdanf" # Ublock Origin
            "jplgfhpmjnbigmhklmmbgecoobifkmpa" # Proton VPN
            "ghmbeldphafepmbegfdlkpapadhbakde" # Proton Pass
            "kekjfbackdeiabghhcdklcdoekaanoel" # MalSync
            "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
            "nffaoalbilbmmfgbnbgppjihopabppdk" # Video Speed Contoller
            "bkijmpolkanhdehnlnabfooghjdokakc" # Double-click Image Downloader
          ];
          ExtensionInstallSources = singleton "https://services.helium.imput.net/*";
          DefaultBrowserSettingEnabled = false;
          DeveloperToolsAvailability = 1;

          # Bookmarks
          ManagedBookmarks =
            let
              createFolder = name: children: { inherit name children; };
              createBookmark = name: url: { inherit name url; };
              createScriptlet =
                name: javascript: createBookmark name ("javascript:" + javascript + "\nvoid undefined;\n");
            in
            [
              { toplevel_name = "Tools"; }
              (createFolder "Archive" [
                (createFolder "Wayback" [
                  (createScriptlet "View" /* javascript */ ''
                    window.open("https://web.archive.org/web/*/" + location.href);
                  '')
                  (createScriptlet "Save" /* javascript */ ''
                    window.open("https://web.archive.org/save/" + location.href);
                  '')
                ])
                (createFolder "Archive.is" [
                  (createScriptlet "View" /* javascript */ ''
                    window.open("https://archive.ph/newest/" + location.href);
                  '')
                  (createScriptlet "Save" /* javascript */ ''
                    window.open("https://archive.ph/?run=1&url=" + encodeURIComponent(location.href));
                  '')
                ])
              ])

              (createFolder "Reverse Image" (
                let
                  mkReverse =
                    name: prefix:
                    createScriptlet name /* javascript */ ''
                      document.addEventListener("click", function handler(event) {
                        let image = event.target.closest("img");
                        if (!image) return;

                        event.preventDefault();
                        event.stopPropagation();
                        document.removeEventListener("click", handler, true);

                        window.open("${prefix}" + encodeURIComponent(image.src));
                      }, true);
                    '';
                in
                [
                  (mkReverse "Yandex" "https://yandex.com/images/search?rpt=imageview&url=")
                  (mkReverse "Google Lens" "https://lens.google.com/uploadbyurl?url=")
                  (mkReverse "Bing" "https://www.bing.com/images/search?view=detailv2&iss=sbi&q=imgurl:")
                  (mkReverse "TinEye" "https://www.tineye.com/search?url=")
                ]
              ))

              (createFolder "Nuke" [
                (createScriptlet "Sticky Elements" /* javascript */ ''
                  document.querySelectorAll("body *").forEach((element) => {
                    let position = getComputedStyle(element).position;
                    if (position === "fixed" || position === "sticky") element.parentNode.removeChild(element);
                  });

                  document.documentElement.style.overflow = "auto";
                  document.body.style.overflow = "auto";
                '')

                (createScriptlet "Copy Paste Restrictions" /* javascript */ ''
                  ["copy", "cut", "paste", "selectstart", "contextmenu", "dragstart"].forEach((eventName) => {
                    document.addEventListener(eventName, (event) => event.stopPropagation(), true);
                  });

                  document.querySelectorAll("*").forEach((element) => {
                    element.style.userSelect = "auto";
                    element.style.webkitUserSelect = "auto";
                  });
                '')
              ])

              (createFolder "Toggle" (
                let
                  mkIndication = text: /* javascript */ ''
                    {
                      let indication = document.body.appendChild(document.createElement("div"));
                      indication.textContent = ${text};

                      Object.assign(indication.style, {
                        position: "fixed",
                        top: "0",
                        left: "0",

                        zIndex: "calc(infinity)",

                        padding: "8px 16px",
                        borderRadius: "8px",

                        colorScheme: "light dark",
                        background: "Canvas",
                        color: "CanvasText",
                        font: "14px/1 system-ui",

                        pointerEvents: "none",
                      });

                      indication.animate(
                        [
                          { opacity: 1, offset: 0.6, easing: "cubic-bezier(0.4, 0, 0.2, 1)" },
                          { opacity: 0, offset: 1 },
                        ],
                        { duration: 1500, fill: "forwards" },
                      )
                      .finished
                      .then(() => indication.remove());
                    }
                  '';
                in
                [
                  (createScriptlet "Password Inputs" /* javascript */ ''
                    let shown = false;
                    document.querySelectorAll("input").forEach((input) => {
                      if (input.type === "password") {
                        input.dataset.wasPassword = "";
                        input.type = "text";
                        shown = true;
                      } else if ("wasPassword" in input.dataset) {
                        delete input.dataset.wasPassword;
                        input.type = "password";
                      }
                    });

                    ${mkIndication /* js */ ''"Passwords " + (shown ? "shown" : "hidden")''}
                  '')

                  (createScriptlet "Design Mode" /* javascript */ ''
                    document.designMode = document.designMode === "on" ? "off" : "on";

                    ${mkIndication /* js */ ''"Design mode " + document.designMode''}
                  '')
                ]
              ))
            ];

          # SEARCH
          DefaultSearchProviderEnabled = true;
          DefaultSearchProviderName = "Brave";
          DefaultSearchProviderSearchURL = "https://search.brave.com/search?q={searchTerms}";
          DefaultSearchProviderSuggestURL = "https://kagi.com/api/autosuggest?q={searchTerms}";
          SearchSuggestEnabled = true;

          SiteSearchSettings =
            let
              createSearchEngine = name: shortcut: url: { inherit name shortcut url; };
              createQuery =
                params:
                let
                  mapFn =
                    name: value:
                    if value == true then "${escapeURL name}={searchTerms}" else "${escapeURL name}=${escapeURL value}";
                in
                mapAttrsToList mapFn params |> concatStringsSep "&";

              createEngine =
                name: alias: url: params:
                let
                  queryStr = createQuery params;
                  fullUrl = if queryStr == "" then url else "${url}?${queryStr}";
                in
                createSearchEngine name alias fullUrl;
            in
            [
              (createEngine "Anilist Anime" "!anime" "https://anilist.co/search/anime" { search = true; })
              (createEngine "Anilist Manga" "!manga" "https://anilist.co/search/manga" { search = true; })
              (createEngine "Arch Wiki" "!archwiki" "https://wiki.archlinux.org/index.php" { search = true; })
              (createEngine "Brave" "!brave" "https://search.brave.com/search" { q = true; })
              (createEngine "Flathub" "!flathub" "https://flathub.org/en/apps/search" { q = true; })
              (createEngine "MyNixOS" "!nix" "https://mynixos.com/search" { q = true; })
              (createEngine "Go" "!go" "https://pkg.go.dev/search" { q = true; })
              (createEngine "YouTube" "!yt" "https://youtube.com/results" { search_query = true; })
              (createEngine "GitHub" "!gh" "https://github.com/search" {
                q = true;
                type = "repositories";
              })
              (createEngine "Home Manager Options" "!home" "https://home-manager-options.extranix.com/" {
                query = true;
                release = "master";
              })
              (createEngine "NixOS Options" "!nixos" "https://search.nixos.org/options" {
                query = true;
                channel = "unstable";
                sort = "relevance";
                type = "options";
              })
              (createEngine "Nix Packages" "!nixpkgs" "https://search.nixos.org/packages" {
                query = true;
                channel = "unstable";
                sort = "relevance";
                type = "packages";
              })
              (createEngine "Wikipedia" "!wiki" "https://en.wikipedia.org/w/index.php" {
                search = true;
                title = "Special:Search";
                profile = "advanced";
                fulltext = "1";
              })
            ];
        });
    in
    {
      packages = singleton inputs.helium.packages.${system}.default;
      preserveHome.directories = singleton ".config/net.imput.helium";
      preserve.directories = singleton "/etc/chromium/policies/managed";

      programs.rong.settings.themes = singleton {
        target = "chromium.json";
        installs = "/tmp/chromium.json";
      };

      systemd.services.chromium-update-theme = {
        description = "Update Chromium managed policy theme color";
        restartTriggers = singleton settings;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${chromiumUpdateTheme} ${settings}";
        };
      };

      systemd.paths.chromium-update-theme = {
        description = "Monitor /tmp/chromium.json for Chromium theme changes";
        wantedBy = singleton "multi-user.target";
        pathConfig = {
          PathChanged = "/tmp/chromium.json";
          Unit = "chromium-update-theme.service";
        };
      };

      systemd.tmpfiles.settings."10-chromium-policy" = {
        "/etc/chromium/policies/managed/policies.json"."C".argument = "${settings}";
      };

      hj.xdg.mime-apps = genMimes "helium.desktop" [
        # Web Pages & Documents
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/xml"
        "application/json"
        "application/pdf"
        # Plain Text
        "text/plain"
        # URI Schemes (Protocols handled by browsers)
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
      ];

    };

}
