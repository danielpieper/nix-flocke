{ pkgs
, config
, lib
, ...
}:
with lib;
let
  cfg = config.services.flocke.valheim;
in
{
  options.services.flocke.valheim = {
    enable = mkEnableOption "Enable Valheim Dedicated Server";

    steamcmdPackage = mkOption {
      type = types.package;
      default = pkgs.steamcmd;
      defaultText = "pkgs.steamcmd";
      description = ''
        The package implementing SteamCMD
      '';
    };

    dataDir = mkOption {
      type = types.path;
      description = "Directory to store game server";
      default = "/var/lib/valheim";
    };

    serverName = mkOption {
      type = types.str;
      description = "Server Name";
      default = "Kirchstein";
    };

    world = mkOption {
      type = types.str;
      description = "Server World Name";
      default = "default";
    };

    port = mkOption {
      type = types.port;
      description = "Server Port";
      default = 2456;
    };

    public = mkOption {
      type = types.bool;
      description = "Add server to the public registry";
      default = false;
    };

    backups = mkOption {
      type = types.bool;
      description = "Create server backups";
      default = false;
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to open ports in the firewall for the server
      '';
    };
  };

  config = mkIf cfg.enable {
    # see: https://dev.to/kevincox/running-a-valheim-dedicated-server-on-nixos-39kj
    # see: https://valheim.fandom.com/wiki/Hosting_Servers#Setting_up_and_running_the_Server
    systemd.services.valheim-server =
      let
        steamcmd = lib.getExe cfg.steamcmdPackage;
        steam-run = lib.getExe pkgs.steam-run;
      in
      {
        description = "Valheim Dedicated Server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          EnvironmentFile = config.sops.secrets.valheim.path;
          TimeoutSec = "15min";
          ExecStart = ''
              ${steam-run} ${cfg.dataDir}/valheim_server.x86_64 \
            -nographics \
            -batchmode \
            -crossplay \
            -savedir ${cfg.dataDir} \
            -name ${cfg.serverName} \
            -port ${toString cfg.port} \
            ${lib.optionalString (cfg.world != "") "-world " + lib.escapeShellArg (cfg.world)} \
            -password $SERVER_PASS \
            -public ${if cfg.public then "1" else "0"} \
            -backups ${if cfg.backups then "1" else "0"}
          '';
          # ExecStart = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2 ${cfg.dataDir}/valheim_server.x86_64 ${lib.escapeShellArgs launchOptions}";
          Restart = "always";
          User = "valheim";
          WorkingDirectory = cfg.dataDir;
        };
        environment = {
          # linux64 directory is required by Valheim.
          LD_LIBRARY_PATH = "linux64:${pkgs.glibc}/lib";
          SERVER_PASS = "test";
        };

        preStart = ''
          ${steamcmd} \
            +force_install_dir "${cfg.dataDir}" \
            +login anonymous \
            +app_update 896660 \
            +quit

          # Fix a missplaced library
          mkdir -p ~/.steam/sdk64
          ln -fs ${cfg.dataDir}/linux64/steamclient.so ~/.steam/sdk64
        '';
      };

    sops.secrets.valheim = {
      owner = config.users.users.valheim.name;
      group = config.users.users.valheim.group;
    };

    users.users.valheim = {
      description = "Valheim server service user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "valheim";
    };
    users.groups.valheim = { };

    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPorts = [
        2456
        2457
      ];
      allowedTCPPorts = [
        2456
        2457
      ];
    };
  };
}
