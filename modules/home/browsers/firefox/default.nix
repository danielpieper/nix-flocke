{
  inputs,
  lib,
  host,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.browsers.firefox;

  mkFirefoxProfile = profileName: profileId: {
    name = profileName;
    id = profileId;

    extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
      onepassword-password-manager
      ublock-origin
      darkreader
      sponsorblock
    ];

    settings = {
      "gnomeTheme.hideSingleTab" = false;
      "gnomeTheme.activeTabContrast" = true;
      "gnomeTheme.hideWebrtcIndicator" = true;
      "gnomeTheme.systemIcons" = true;
      "gnomeTheme.bookmarksOnFullscreen" = true;
      "layers.acceleration.force-enabled" = true;
      "identity.fxaccounts.account.device.name" = "${config.flocke.user.name}@${host}";
      "extensions.pocket.enabled" = false;
      "browser.urlbar.suggest.engines" = false;
      "browser.urlbar.suggest.openpage" = false;
      "browser.urlbar.suggest.bookmark" = false;
      "browser.urlbar.suggest.addons" = false;
      "browser.urlbar.suggest.pocket" = false;
      "browser.urlbar.suggest.topsites" = false;

      # Disable irritating first-run stuff
      "browser.disableResetPrompt" = true;
      "browser.download.panel.shown" = true;
      "browser.feeds.showFirstRunUI" = false;
      "browser.messaging-system.whatsNewPanel.enabled" = false;
      "browser.rights.3.shown" = true;
      "browser.shell.checkDefaultBrowser" = false;
      "browser.shell.defaultBrowserCheckCount" = 1;
      "browser.startup.homepage_override.mstone" = "ignore";
      "browser.uitour.enabled" = false;
      "startup.homepage_override_url" = "";
      "trailhead.firstrun.didSeeAboutWelcome" = true;
      "browser.bookmarks.restore_default_bookmarks" = false;
      "browser.bookmarks.addedImportButton" = true;

      # Disable some telemetry
      "app.shield.optoutstudies.enabled" = false;
      "browser.discovery.enabled" = false;
      "browser.newtabpage.activity-stream.feeds.telemetry" = false;
      "browser.newtabpage.activity-stream.telemetry" = false;
      "browser.ping-centre.telemetry" = false;
      "datareporting.healthreport.service.enabled" = false;
      "datareporting.healthreport.uploadEnabled" = false;
      "datareporting.policy.dataSubmissionEnabled" = false;
      "datareporting.sessions.current.clean" = true;
      "devtools.onboarding.telemetry.logged" = false;
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "toolkit.telemetry.hybridContent.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.prompted" = 2;
      "toolkit.telemetry.rejected" = true;
      "toolkit.telemetry.reportingpolicy.firstRun" = false;
      "toolkit.telemetry.server" = "";
      "toolkit.telemetry.shutdownPingSender.enabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.unifiedIsOptIn" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
    };
    search = {
      force = true;
      default = "SearXNG";
      privateDefault = "SearXNG";
      order = [
        "SearXNG"
        "ddg"
        "google"
        "NixOS Options"
        "Nix Packages"
        "Home Manager"
        "NixOS Wiki"
        "GitHub"
        "dict.cc"
        "youtube"
      ];
      # FIXME: Search engine icons are broken, see https://github.com/nix-community/home-manager/issues/6450
      engines = {
        "ebay".metaData.hidden = true;
        "leo_ende_de".metaData.hidden = true;
        "amazondotcom-us".metaData.hidden = true;
        "ecosia".metaData.hidden = true;
        "wikipedia-de".metaData.alias = "@wp";
        "google".metaData.alias = "@g";
        "ddg".metaData.alias = "@ddg";
        "SearXNG" = {
          icon = "https://search.homelab.daniel-pieper.com/favicon.ico";
          definedAliases = [ "@s" ];
          urls = [
            {
              template = "https://search.homelab.daniel-pieper.com/search";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
        };
        "dict.cc" = {
          icon = "https://www.dict.cc/favicon.ico";
          definedAliases = [ "@d" ];
          urls = [
            {
              template = "https://www.dict.cc/";
              params = [
                {
                  name = "s";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
        };
        "youtube" = {
          icon = "https://youtube.com/favicon.ico";
          definedAliases = [ "@yt" ];
          updateInterval = 24 * 60 * 60 * 1000;
          urls = [
            {
              template = "https://www.youtube.com/results";
              params = [
                {
                  name = "search_query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
        };
        "Nix Packages" = {
          icon = "https://nixos.org/favicon.ico";
          definedAliases = [ "@np" ];
          urls = [
            {
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
                {
                  name = "channel";
                  value = "unstable";
                }
              ];
            }
          ];
        };
        "NixOS Options" = {
          icon = "https://nixos.org/favicon.ico";
          definedAliases = [ "@no" ];
          urls = [
            {
              template = "https://search.nixos.org/options";
              params = [
                {
                  name = "channel";
                  value = "unstable";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
        };
        "GitHub" = {
          icon = "https://github.com/favicon.ico";
          definedAliases = [ "@gh" ];
          updateInterval = 24 * 60 * 60 * 1000;
          urls = [
            {
              template = "https://github.com/search";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
        };
        "NixOS Wiki" = {
          icon = "https://wiki.nixos.org/favicon.png";
          definedAliases = [ "@nw" ];
          updateInterval = 24 * 60 * 60 * 1000; # every day
          urls = [
            {
              template = "https://wiki.nixos.org/index.php";
              params = [
                {
                  name = "search";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
        };
        "Home Manager" = {
          icon = "https://nixos.org/favicon.ico";
          definedAliases = [ "@hm" ];
          urls = [
            {
              template = "https://home-manager-options.extranix.com/";
              params = [
                {
                  name = "query";
                  value = "{searchTerms}";
                }
                {
                  name = "release";
                  value = "master";
                }
              ];
            }
          ];
        };
      };
    };

    userChrome = builtins.readFile "${inputs.firefox-gnome-theme}/userChrome.css";
    userContent = builtins.readFile "${inputs.firefox-gnome-theme}/userContent.css";
    extraConfig = builtins.readFile "${inputs.firefox-gnome-theme}/configuration/user.js";
  };
in
{
  options.browsers.firefox = {
    enable = mkEnableOption "Enable firefox browser";
    defaultLinkProfile = mkOption {
      description = "Name of the profile to use for opening links (must match one of the additionalProfiles names)";
      type = types.nullOr types.str;
      default = null;
      example = "Work";
    };
    additionalProfiles = mkOption {
      description = "Additional Firefox profiles to create using the standard configuration";
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Name of the Firefox profile";
              example = "Work";
            };
            id = mkOption {
              type = types.int;
              description = "ID of the Firefox profile (sequential from 1)";
              example = 1;
            };
          };
        }
      );
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    # Allow specifying which profile should be used for opening links
    xdg.mimeApps.defaultApplications =
      let
        # Use the specified profile for links or fall back to the default firefox.desktop
        browserDesktopEntry =
          if cfg.defaultLinkProfile != null then
            "firefox-${lib.toLower cfg.defaultLinkProfile}.desktop"
          else
            "firefox.desktop";
      in
      {
        "text/html" = [ browserDesktopEntry ];
        "text/xml" = [ browserDesktopEntry ];
        "x-scheme-handler/http" = [ browserDesktopEntry ];
        "x-scheme-handler/https" = [ browserDesktopEntry ];
      };

    programs.firefox = {
      enable = true;
      languagePacks = [
        "en-US"
        "de"
      ];
      profiles =
        lib.foldl'
          (
            acc: profile:
            acc
            // {
              "${lib.toLower profile.name}" = mkFirefoxProfile profile.name profile.id;
            }
          )
          {
            default = mkFirefoxProfile "Default" 0;
          }
          cfg.additionalProfiles;
    };

    stylix.targets.firefox.profileNames = [
      "default"
    ] ++ (map (profile: lib.toLower profile.name) cfg.additionalProfiles);

    xdg.desktopEntries = lib.foldl' (
      acc: profile:
      acc
      // {
        "firefox-${lib.toLower profile.name}" = {
          name = "Firefox - ${profile.name}";
          genericName = "Web Browser - ${profile.name}";
          exec = "firefox -P ${profile.name} %U";
          terminal = false;
          icon = "firefox";
          startupNotify = true;
          categories = [
            "Application"
            "Network"
            "WebBrowser"
          ];
          mimeType = [
            "text/html"
            "text/xml"
          ];
        };
      }
    ) { } cfg.additionalProfiles;
  };
}
