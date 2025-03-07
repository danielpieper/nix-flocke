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
    ];

    settings = {
      "gnomeTheme.hideSingleTab" = false;
      "gnomeTheme.activeTabContrast" = true;
      "gnomeTheme.hideWebrtcIndicator" = true;
      "gnomeTheme.systemIcons" = true;
      "gnomeTheme.bookmarksOnFullscreen" = true;
      "layers.acceleration.force-enabled" = true;
      "identity.fxaccounts.account.device.name" = "${config.flocke.user.name}@${host}";
      "browser.urlbar.oneOffSearches" = false;
      "browser.search.hiddenOneOffs" = "Google,Yahoo,Bing,Amazon.com,Twitter,Wikipedia (en),YouTube,eBay";
      "extensions.pocket.enabled" = false;
      "browser.urlbar.suggest.engines" = false;
      "browser.urlbar.suggest.openpage" = false;
      "browser.urlbar.suggest.bookmark" = false;
      "browser.urlbar.suggest.addons" = false;
      "browser.urlbar.suggest.pocket" = false;
      "browser.urlbar.suggest.topsites" = false;
    };

    userChrome = builtins.readFile "${inputs.firefox-gnome-theme}/userChrome.css";
    userContent = builtins.readFile "${inputs.firefox-gnome-theme}/userContent.css";
    extraConfig = builtins.readFile "${inputs.firefox-gnome-theme}/configuration/user.js";
  };
in
{
  options.browsers.firefox = {
    enable = mkEnableOption "enable firefox browser";
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
            createDesktopEntry = mkOption {
              type = types.bool;
              description = "Whether to create a desktop entry for this profile";
              default = true;
            };
          };
        }
      );
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    xdg.mimeApps.defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "text/xml" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
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
      if profile.createDesktopEntry then
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
      else
        acc
    ) { } cfg.additionalProfiles;
  };
}
