{
  pkgs,
  config,
  lib,
  ...
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
      default = "BamBam2";
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

    modifiers = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        deathpenalty = "casual";
        raids = "less";
      };
      description = ''
        World modifiers passed as `-modifier <key> <value>`.
        See https://valheim.fandom.com/wiki/World_Modifiers
      '';
    };

    adminList = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "Steam_76561197960287930" ];
      description = ''
        Platform IDs (e.g. `Steam_<id>`, `PlayStation_<id>`) written to adminlist.txt.
        Admins are automatically added to the permitted list.
      '';
    };

    permittedList = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "Steam_76561197960287930" ];
      description = ''
        Platform IDs written to permittedlist.txt. When non-empty, only these
        players (plus admins) may join.
      '';
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
        adminListFile = pkgs.writeText "valheim-adminlist.txt" (
          concatLines ([ "// List admin players ID  ONE per line" ] ++ cfg.adminList)
        );
        permittedListFile = pkgs.writeText "valheim-permittedlist.txt" (
          concatLines (
            [ "// List permitted players ID ONE per line" ] ++ unique (cfg.adminList ++ cfg.permittedList)
          )
        );
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
            ${lib.optionalString (cfg.world != "") "-world " + lib.escapeShellArg cfg.world} \
            -password $SERVER_PASS \
            -public ${if cfg.public then "1" else "0"} \
            -backups ${if cfg.backups then "1" else "0"} \
            ${concatStringsSep " " (mapAttrsToList (k: v: "-modifier ${k} ${v}") cfg.modifiers)}
          '';
          # ExecStart = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2 ${cfg.dataDir}/valheim_server.x86_64 ${lib.escapeShellArgs launchOptions}";
          Restart = "always";
          User = "valheim";
          WorkingDirectory = cfg.dataDir;
        };
        environment = {
          # linux64 directory is required by Valheim.
          LD_LIBRARY_PATH = "linux64:${pkgs.glibc}/lib";
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

          # Declaratively managed player lists
          cp --no-preserve=mode ${adminListFile} ${cfg.dataDir}/adminlist.txt
          cp --no-preserve=mode ${permittedListFile} ${cfg.dataDir}/permittedlist.txt
        '';
      };

    sops.secrets.valheim = {
      owner = config.users.users.valheim.name;
      inherit (config.users.users.valheim) group;
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
