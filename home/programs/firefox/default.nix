{ inputs, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles."Default" = {
      search = {
        force = true;
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          "Home-manager Options" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com";
                params = [
                  {
                    name = "release";
                    value = "master";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@hm" ];
          };
        };
      };
      settings = {
        "browser.startup.homepage" = "https://dashboard.cleroux.dev";
        "browser.aboutConfig.showWarning" = false;
        "browser.search.region" = "CA";
        "browser.search.isUS" = false;
        "browser.urlbar.showSearchSuggestionsFirst" = false;
        "browser.search.suggest.enabled.private" = false;
        "distribution.searchplugins.defaultLocale" = "en-CA";
        "general.useragent.locale" = "en-CA";
        "datareporting.healthreport.uploadEnabled" = false;
        "signon.rememberSignons" = false;

        "font.default.x-western" = "sans-serif";
        "font.size.variable.x-western" = 16;
        "font.size.monospace.x-western" = 16;
        "layout.css.devPixelsPerPx" = 2.2;

        # Bookmarks
        "browser.toolbars.bookmarks.visibility" = "always";
        "distribution.nixos.bookmarksProcessed" = true;
        "browser.bookmarks.showMobileBookmarks" = true;
        "browser.bookmarks.restore_default_bookmarks" = false;

        # Privacy
        "privacy.history.custom" = true;
        "places.history.enabled" = true;
        "browser.formfill.enable" = false;
        "extensions.autoDisableScopes" = 0;
        "dom.forms.autocomplete.formautofill" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "network.trr.mode" = 5; # Use system DNS resolver

        # New tab page
        "browser.newtabpage.activity-stream.showSearch" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.showWeather" = false;
        "browser.newtabpage.activity-stream.feeds.section.highlights" = true;
        "browser.newtabpage.activity-stream.section.highlights.rows" = 3;
        "browser.newtabpage.activity-stream.newtabWallpapers.highlightDismissed" = true;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        # Disable extensions recommendations
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;

      };
      extensions.force = true;
      # https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/addons.json?ref_type=heads
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
        bitwarden
        dearrow
        return-youtube-dislikes
        sponsorblock
        ublock-origin
      ];
    };
  };
}
