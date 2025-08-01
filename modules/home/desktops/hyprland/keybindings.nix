{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.desktops.hyprland;

  resize = pkgs.writeShellScriptBin "resize" ''
    #!/usr/bin/env bash

    # Initially inspired by https://github.com/exoess

    # Getting some information about the current window
    # windowinfo=$(hyprctl activewindow) removes the newlines and won't work with grep
    hyprctl activewindow > /tmp/windowinfo
    windowinfo=/tmp/windowinfo

    # Run slurp to get position and size
    if ! slurp=$(slurp); then
    		exit
    fi

    # Parse the output
    pos_x=$(echo $slurp | cut -d " " -f 1 | cut -d , -f 1)
    pos_y=$(echo $slurp | cut -d " " -f 1 | cut -d , -f 2)
    size_x=$(echo $slurp | cut -d " " -f 2 | cut -d x -f 1)
    size_y=$(echo $slurp | cut -d " " -f 2 | cut -d x -f 2)

    # Keep the aspect ratio intact for PiP
    if grep "title: Picture-in-Picture" $windowinfo; then
    		old_size=$(grep "size: " $windowinfo | cut -d " " -f 2)
    		old_size_x=$(echo $old_size | cut -d , -f 1)
    		old_size_y=$(echo $old_size | cut -d , -f 2)

    		size_x=$(((old_size_x * size_y + old_size_y / 2) / old_size_y))
    		echo $old_size_x $old_size_y $size_x $size_y
    fi

    # Resize and move the (now) floating window
    grep "fullscreen: 1" $windowinfo && hyprctl dispatch fullscreen
    grep "floating: 0" $windowinfo && hyprctl dispatch togglefloating
    hyprctl dispatch moveactive exact $pos_x $pos_y
    hyprctl dispatch resizeactive exact $size_x $size_y
  '';
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      bind = [
        "SUPER, Return, exec, wezterm"
        "SUPER, Q, killactive,"
        "SUPER, F, Fullscreen,0"
        "SUPER, S, togglesplit"
        "SUPER, B, togglefloating,"
        "SUPER, R, exec, ${resize}/bin/resize"
        "SUPER, Space, exec, ${config.desktops.addons.rofi.package}/bin/rofi -show drun -mode drun"

        # Lock Screen
        ",XF86Launch5, exec,${pkgs.hyprlock}/bin/hyprlock"
        ",XF86Launch4, exec,${pkgs.hyprlock}/bin/hyprlock"
        "SUPER,backspace, exec,${pkgs.hyprlock}/bin/hyprlock"
        "CTRL_SUPER,backspace, exec,wlogout --column-spacing 50 --row-spacing 50"

        # Screenshot
        ",Print, exec,${pkgs.grimblast}/bin/grimblast save area - | ${pkgs.satty}/bin/satty -f - -o ~/Pictures/Screenshots/%Y-%m-%d_%H:%M:%S.png"
        "SHIFT, Print, exec,${pkgs.grimblast}/bin/grimblast save active - | ${pkgs.satty}/bin/satty -f - -o ~/Pictures/Screenshots/%Y-%m-%d_%H:%M:%S.png"
        "CONTROL,Print, exec,${pkgs.grimblast}/bin/grimblast save screen - | ${pkgs.satty}/bin/satty -f - -o ~/Pictures/Screenshots/%Y-%m-%d_%H:%M:%S.png"

        # Focus
        "SUPER,h, movefocus,l"
        "SUPER,l, movefocus,r"
        "SUPER,k, movefocus,u"
        "SUPER,j, movefocus,d"
        "SUPERCONTROL,h, focusmonitor,l"
        "SUPERCONTROL,l, focusmonitor,r"
        "SUPERCONTROL,k, focusmonitor,u"
        "SUPERCONTROL,j, focusmonitor,d"

        # Change Workspace
        "SUPER,1, workspace,01"
        "SUPER,2, workspace,02"
        "SUPER,3, workspace,03"
        "SUPER,4, workspace,04"
        "SUPER,5, workspace,05"
        "SUPER,6, workspace,06"
        "SUPER,7, workspace,07"
        "SUPER,8, workspace,08"
        "SUPER,9, workspace,09"
        "SUPER,0, workspace,10"

        # Move Workspace
        "SUPERSHIFT,1, movetoworkspacesilent,01"
        "SUPERSHIFT,2, movetoworkspacesilent,02"
        "SUPERSHIFT,3, movetoworkspacesilent,03"
        "SUPERSHIFT,4, movetoworkspacesilent,04"
        "SUPERSHIFT,5, movetoworkspacesilent,05"
        "SUPERSHIFT,6, movetoworkspacesilent,06"
        "SUPERSHIFT,7, movetoworkspacesilent,07"
        "SUPERSHIFT,8, movetoworkspacesilent,08"
        "SUPERSHIFT,9, movetoworkspacesilent,09"
        "SUPERSHIFT,0, movetoworkspacesilent,10"
        "SUPERALT,h, movecurrentworkspacetomonitor,l"
        "SUPERALT,l, movecurrentworkspacetomonitor,r"
        "SUPERALT,k, movecurrentworkspacetomonitor,u"
        "SUPERALT,j, movecurrentworkspacetomonitor,d"
        "ALTCTRL,L, movewindow,r"
        "ALTCTRL,H, movewindow,l"
        "ALTCTRL,K, movewindow,u"
        "ALTCTRL,J, movewindow,d"

        # Swap windows
        "SUPERSHIFT,h, swapwindow,l"
        "SUPERSHIFT,l, swapwindow,r"
        "SUPERSHIFT,k, swapwindow,u"
        "SUPERSHIFT,j, swapwindow,d"

        # Scratch Pad
        "SUPER,u, togglespecialworkspace"
        "SUPERSHIFT,u, movetoworkspace,special"
      ];
      bindi = [
        ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl -q s +10%"
        ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl -q s 10%-"
        ",XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer -i 5"
        ",XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer -d 5"
        ",XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer --toggle-mute"
        ",XF86AudioMicMute, exec, ${pkgs.pamixer}/bin/pamixer --default-source --toggle-mute"
        ",XF86AudioNext, exec,playerctl next"
        ",XF86AudioPrev, exec,playerctl previous"
        ",XF86AudioPlay, exec,playerctl play-pause"
        ",XF86AudioStop, exec,playerctl stop"
      ];
      binde = [
        "SUPERALT, h, resizeactive, -20 0"
        "SUPERALT, l, resizeactive, 20 0"
        "SUPERALT, k, resizeactive, 0 -20"
        "SUPERALT, j, resizeactive, 0 20"
      ];
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };
}
