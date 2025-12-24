{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.flocke.home-assistant;
in
{
  options.services.flocke.home-assistant = {
    enable = mkEnableOption "Enable Home Assistant";
  };

  config = mkIf cfg.enable {
    services = {
      home-assistant = {
        enable = true;
        package = pkgs.home-assistant.override { extraPackages = ps: [ ps.psycopg2 ]; };
        extraPackages =
          python3Packages: with python3Packages; [
            pychromecast
          ];
        configWritable = true;

        extraComponents = [
          "pushover"
          "roborock"
          "otbr"
          "matter"
          "thread"
          "google_translate"
          "alexa_devices"
          "android_ip_webcam"
        ];
        config =
          # let
          #   hiddenEntities = [
          #     "sensor.last_boot"
          #     "sensor.date"
          #   ];
          # in
          {
            # icloud = { };
            frontend = { };
            http = {
              use_x_forwarded_for = true;
              trusted_proxies = [
                "127.0.0.1"
                "::1"
              ];
            };
            # history.exclude = {
            #   # entities = hiddenEntities;
            #   domains = [
            #     "automation"
            #     "updater"
            #   ];
            # };
            "map" = { };
            shopping_list = { };
            backup = { };
            # logbook.exclude.entities = hiddenEntities;
            logger.default = "info";
            sun = { };
            prometheus.filter.include_domains = [ "persistent_notification" ];
            # device_tracker = [
            #   {
            #     platform = "luci";
            #     host = "rauter.r";
            #     username = "!secret openwrt_user";
            #     password = "!secret openwrt_password";
            #   }
            # ];
            config = { };
            mobile_app = { };

            #icloud = {
            #  username = "!secret icloud_email";
            #  password = "!secret icloud_password";
            #  with_family = true;
            #};
            cloud = { };
            network = { };
            zeroconf = { };
            system_health = { };
            default_config = { };
            system_log = { };
            automation = "!include automations.yaml";
            # sensor = [
            #   {
            #     platform = "template";
            #     sensors.shannan_joerg_distance.value_template = ''{{ distance('person.jorg_thalheim', 'person.shannan_lekwati') | round(2) }}'';
            #     sensors.joerg_last_updated = {
            #       friendly_name = "Jörg's last location update";
            #       value_template = ''{{ states.person.jorg_thalheim.last_updated.strftime('%Y-%m-%dT%H:%M:%S') }}Z'';
            #       device_class = "timestamp";
            #     };
            #     sensors.shannan_last_updated = {
            #       friendly_name = "Shannan's last location update";
            #       value_template = ''{{ states.person.shannan_lekwati.last_updated.strftime('%Y-%m-%dT%H:%M:%S') }}Z'';
            #       device_class = "timestamp";
            #     };
            #   }
            # ];
            recorder.db_url = "postgresql://@/hass";
          };
      };
      postgresql = {
        ensureDatabases = [ "hass" ];
        ensureUsers = [
          {
            name = "hass";
            ensureDBOwnership = true;
          }
        ];
      };
      matter-server = {
        enable = true;
        # logLevel = "debug";
        port = 5580;
      };
      traefik = {
        dynamicConfigOptions = {
          http = {
            services = {
              home-assistant.loadBalancer.servers = [
                {
                  url = "http://127.0.0.1:8123";
                }
              ];
            };

            routers = {
              home-assistant = {
                entryPoints = [ "websecure" ];
                rule = "Host(`home.homelab.${inputs.nix-secrets.domain}`)";
                service = "home-assistant";
              };
            };
          };
        };
      };
    };
  };
}
