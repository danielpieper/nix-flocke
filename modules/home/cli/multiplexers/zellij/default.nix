{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.multiplexers.zellij;
  inherit (config.lib.stylix) colors;

  sesh = pkgs.writeScriptBin "sesh" ''
    #! /usr/bin/env sh

    # Taken from https://github.com/zellij-org/zellij/issues/884#issuecomment-1851136980
    # select a directory using zoxide
    ZOXIDE_RESULT=$(zoxide query --interactive)
    # checks whether a directory has been selected
    if [[ -z "$ZOXIDE_RESULT" ]]; then
    	# if there was no directory, select returns without executing
    	exit 0
    fi
    # extracts the directory name from the absolute path
    SESSION_TITLE=$(echo "$ZOXIDE_RESULT" | sed 's#.*/##')

    # get the list of sessions
    SESSION_LIST=$(zellij list-sessions -n | awk '{print $1}')

    # checks if SESSION_TITLE is in the session list
    if echo "$SESSION_LIST" | grep -q "^$SESSION_TITLE$"; then
    	# if so, attach to existing session
    	zellij attach "$SESSION_TITLE"
    else
    	# if not, create a new session
    	echo "Creating new session $SESSION_TITLE and CD $ZOXIDE_RESULT"
    	cd $ZOXIDE_RESULT
    	zellij attach -c "$SESSION_TITLE"
    fi
  '';
in
{
  options.cli.multiplexers.zellij = with types; {
    enable = mkBoolOpt false "enable zellij multiplexer";
  };

  config = mkIf cfg.enable {
    home.packages = [
      sesh
      pkgs.tmate
    ];
    programs.zoxide.enable = true;

    # https://haseebmajid.dev/posts/2024-07-26-how-i-configured-zellij-status-bar/
    programs.zellij = {
      enable = true;
      enableFishIntegration = lib.mkForce false;
    };

    xdg.configFile = {
      "zellij/config.kdl".text = ''
        theme "catppuccin-mocha"
        pane_frames false
        simplified_ui true
        default_shell "fish"
        copy_on_select true
        session_serialization false
        show_startup_tips false

        plugins {
          session-manager { path "session-manager"; }
        }

        keybinds {
          normal clear-defaults=true {
            // tmux
            bind "Ctrl b" { SwitchToMode "Tmux"; }
            // general stuff
            bind "Alt Left" { NewPane "Left"; }
            bind "Alt Right" { NewPane "Right"; }
            bind "Alt Up" { NewPane "Up"; }
            bind "Alt Down" { NewPane "Up"; }
            bind "Alt x" { CloseFocus; SwitchToMode "Normal"; }
            bind "Alt w" { ToggleFloatingPanes;}
            bind "Alt t" { NewTab;}
            bind "Alt h" { MoveFocusOrTab "Left"; }
            bind "Alt l" { MoveFocusOrTab "Right"; }
            bind "Alt j" { MoveFocus "Down"; }
            bind "Alt k" { MoveFocus "Up"; }
            bind "Alt =" { Resize "Increase"; }
            bind "Alt -" { Resize "Decrease"; }
            bind "Alt [" { PreviousSwapLayout; }
            bind "Alt ]" { NextSwapLayout; }
            bind "Alt i" { MoveTab "Left"; }
            bind "Alt o" { MoveTab "Right"; }
          }

          tmux clear-defaults=true {
            bind "Ctrl f" { Write 2; SwitchToMode "Normal"; }
            bind "Esc" { SwitchToMode "Normal"; }
            bind "g" { SwitchToMode "Locked"; }
            bind "p" { SwitchToMode "Pane"; }
            bind "t" { SwitchToMode "Tab"; }
            bind "n" { SwitchToMode "Resize"; }
            bind "h" { SwitchToMode "Move"; }
            bind "s" { SwitchToMode "Scroll"; }
            bind "o" { SwitchToMode "Session"; }
            bind "q" { Quit; }
            bind "?" {
              SwitchToMode "Normal";
              LaunchOrFocusPlugin "https://github.com/karimould/zellij-forgot/releases/download/0.4.2/zellij_forgot.wasm" {
                "lock"                  "ctrl + b + g"
                "unlock"                "ctrl + g"
                "new pane left"         "alt + left"
                "new pane right"        "alt + right"
                "new pane up"           "alt + up"
                "new pane down"         "alt + down"
                "close tab"             "alt + x"
                "toggle floating pane"  "alt + w"
                "new tab"               "alt + t"
                "move left"             "alt + h"
                "move right"            "alt + l"
                "move up"               "alt + j"
                "move down"             "alt + k"
                "resize increase"       "alt + ="
                "resize decrease"       "alt + -"
                "next layout"           "alt + ]"
                "previous layout"       "alt + ["
                "move tab left"         "alt + i"
                "move tab right"        "alt + o"
                "change focus of pane"  "ctrl + b + p + arrow key"
                "close pane"            "ctrl + b + p + x"
                "rename pane"           "ctrl + b + p + c"
                "toggle fullscreen"     "ctrl + b + p + f"
                "toggle floating pane"  "ctrl + b + p + w"
                "toggle embed pane"     "ctrl + b + p + e"
                "choose right pane"     "ctrl + b + p + l"
                "choose left pane"      "ctrl + b + p + r"
                "choose upper pane"     "ctrl + b + p + k"
                "choose lower pane"     "ctrl + b + p + j"
                "new tab"               "ctrl + b + t + n"
                "close tab"             "ctrl + b + t + x"
                "change focus of tab"   "ctrl + b + t + arrow key"
                "rename tab"            "ctrl + b + t + r"
                "sync tab"              "ctrl + b + t + s"
                "brake pane to new tab" "ctrl + b + t + b"
                "brake pane left"       "ctrl + b + t + ["
                "brake pane right"      "ctrl + b + t + ]"
                "toggle tab"            "ctrl + b + t + tab"
                "increase pane size"    "ctrl + b + n + +"
                "decrease pane size"    "ctrl + b + n + -"
                "increase pane top"     "ctrl + b + n + k"
                "increase pane right"   "ctrl + b + n + l"
                "increase pane bottom"  "ctrl + b + n + j"
                "increase pane left"    "ctrl + b + n + h"
                "decrease pane top"     "ctrl + b + n + K"
                "decrease pane right"   "ctrl + b + n + L"
                "decrease pane bottom"  "ctrl + b + n + J"
                "decrease pane left"    "ctrl + b + n + H"
                "move pane to top"      "ctrl + b + h + k"
                "move pane to right"    "ctrl + b + h + l"
                "move pane to bottom"   "ctrl + b + h + j"
                "move pane to left"     "ctrl + b + h + h"
                "search"                "ctrl + b + s + s"
                "go into edit mode"     "ctrl + b + s + e"
                "detach session"        "ctrl + b + o + w"
                "open session manager"  "ctrl + b + o + w"
                "quit zellij"           "ctrl + b + q"
                floating true
              }
            }
          }
        }
      '';
      "zellij/layouts/default.kdl".text = ''
        layout {
            swap_tiled_layout name="vertical" {
                tab max_panes=5 {
                    pane split_direction="vertical" {
                        pane
                        pane { children; }
                    }
                }
                tab max_panes=8 {
                    pane split_direction="vertical" {
                        pane { children; }
                        pane { pane; pane; pane; pane; }
                    }
                }
                tab max_panes=12 {
                    pane split_direction="vertical" {
                        pane { children; }
                        pane { pane; pane; pane; pane; }
                        pane { pane; pane; pane; pane; }
                    }
                }
            }

            swap_tiled_layout name="horizontal" {
                tab max_panes=5 {
                    pane
                    pane
                }
                tab max_panes=8 {
                    pane {
                        pane split_direction="vertical" { children; }
                        pane split_direction="vertical" { pane; pane; pane; pane; }
                    }
                }
                tab max_panes=12 {
                    pane {
                        pane split_direction="vertical" { children; }
                        pane split_direction="vertical" { pane; pane; pane; pane; }
                        pane split_direction="vertical" { pane; pane; pane; pane; }
                    }
                }
            }

            swap_tiled_layout name="stacked" {
                tab min_panes=5 {
                    pane split_direction="vertical" {
                        pane
                        pane stacked=true { children; }
                    }
                }
            }

            swap_floating_layout name="staggered" {
                floating_panes
            }

            swap_floating_layout name="enlarged" {
                floating_panes max_panes=10 {
                    pane { x "5%"; y 1; width "90%"; height "90%"; }
                    pane { x "5%"; y 2; width "90%"; height "90%"; }
                    pane { x "5%"; y 3; width "90%"; height "90%"; }
                    pane { x "5%"; y 4; width "90%"; height "90%"; }
                    pane { x "5%"; y 5; width "90%"; height "90%"; }
                    pane { x "5%"; y 6; width "90%"; height "90%"; }
                    pane { x "5%"; y 7; width "90%"; height "90%"; }
                    pane { x "5%"; y 8; width "90%"; height "90%"; }
                    pane { x "5%"; y 9; width "90%"; height "90%"; }
                    pane focus=true { x 10; y 10; width "90%"; height "90%"; }
                }
            }

            swap_floating_layout name="spread" {
                floating_panes max_panes=1 {
                    pane {y "50%"; x "50%"; }
                }
                floating_panes max_panes=2 {
                    pane { x "1%"; y "25%"; width "45%"; }
                    pane { x "50%"; y "25%"; width "45%"; }
                }
                floating_panes max_panes=3 {
                    pane focus=true { y "55%"; width "45%"; height "45%"; }
                    pane { x "1%"; y "1%"; width "45%"; }
                    pane { x "50%"; y "1%"; width "45%"; }
                }
                floating_panes max_panes=4 {
                    pane { x "1%"; y "55%"; width "45%"; height "45%"; }
                    pane focus=true { x "50%"; y "55%"; width "45%"; height "45%"; }
                    pane { x "1%"; y "1%"; width "45%"; height "45%"; }
                    pane { x "50%"; y "1%"; width "45%"; height "45%"; }
                }
            }

            default_tab_template {
                pane size=1 borderless=true {
                    plugin location="file://${pkgs.zjstatus}/bin/zjstatus.wasm" {
                        format_left   "{mode}#[bg=#${colors.base00}] {tabs}"
                        format_center "{notifications}"
                        format_right  "#[bg=#${colors.base00},fg=#${colors.base0D}]#[bg=#${colors.base0D},fg=#${colors.base01},bold] #[bg=#${colors.base02},fg=#${colors.base05},bold] {swap_layout} {session} #[bg=#${colors.base03},fg=#${colors.base05},bold]"
                        format_space  ""
                        format_hide_on_overlength "true"
                        format_precedence "crl"

                        border_enabled  "false"
                        border_char     "─"
                        border_format   "#[fg=#6C7086]{char}"
                        border_position "top"

                        mode_normal        "#[bg=#${colors.base0B},fg=#${colors.base02},bold] NORMAL#[bg=#${colors.base03},fg=#${colors.base0B}]█"
                        mode_locked        "#[bg=#${colors.base04},fg=#${colors.base02},bold] LOCKED #[bg=#${colors.base03},fg=#${colors.base04}]█"
                        mode_resize        "#[bg=#${colors.base08},fg=#${colors.base02},bold] RESIZE#[bg=#${colors.base03},fg=#${colors.base08}]█"
                        mode_pane          "#[bg=#${colors.base0D},fg=#${colors.base02},bold] PANE#[bg=#${colors.base03},fg=#${colors.base0D}]█"
                        mode_tab           "#[bg=#${colors.base07},fg=#${colors.base02},bold] TAB#[bg=#${colors.base03},fg=#${colors.base07}]█"
                        mode_scroll        "#[bg=#${colors.base0A},fg=#${colors.base02},bold] SCROLL#[bg=#${colors.base03},fg=#${colors.base0A}]█"
                        mode_enter_search  "#[bg=#${colors.base0D},fg=#${colors.base02},bold] ENT-SEARCH#[bg=#${colors.base03},fg=#${colors.base0D}]█"
                        mode_search        "#[bg=#${colors.base0D},fg=#${colors.base02},bold] SEARCHARCH#[bg=#${colors.base03},fg=#${colors.base0D}]█"
                        mode_rename_tab    "#[bg=#${colors.base07},fg=#${colors.base02},bold] RENAME-TAB#[bg=#${colors.base03},fg=#${colors.base07}]█"
                        mode_rename_pane   "#[bg=#${colors.base0D},fg=#${colors.base02},bold] RENAME-PANE#[bg=#${colors.base03},fg=#${colors.base0D}]█"
                        mode_session       "#[bg=#${colors.base0E},fg=#${colors.base02},bold] SESSION#[bg=#${colors.base03},fg=#${colors.base0E}]█"
                        mode_move          "#[bg=#${colors.base0F},fg=#${colors.base02},bold] MOVE#[bg=#${colors.base03},fg=#${colors.base0F}]█"
                        mode_prompt        "#[bg=#${colors.base0D},fg=#${colors.base02},bold] PROMPT#[bg=#${colors.base03},fg=#${colors.base0D}]█"
                        mode_tmux          "#[bg=#${colors.base09},fg=#${colors.base02},bold] TMUX#[bg=#${colors.base03},fg=#${colors.base09}]█"

                        // formatting for inactive tabs
                        tab_normal              "#[bg=#${colors.base03},fg=#${colors.base0D}]█#[bg=#${colors.base0D},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{floating_indicator}#[bg=#${colors.base03},fg=#${colors.base02},bold]█"
                        tab_normal_fullscreen   "#[bg=#${colors.base03},fg=#${colors.base0D}]█#[bg=#${colors.base0D},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{fullscreen_indicator}#[bg=#${colors.base03},fg=#${colors.base02},bold]█"
                        tab_normal_sync         "#[bg=#${colors.base03},fg=#${colors.base0D}]█#[bg=#${colors.base0D},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{sync_indicator}#[bg=#${colors.base03},fg=#${colors.base02},bold]█"

                        // formatting for the current active tab
                        tab_active              "#[bg=#${colors.base03},fg=#${colors.base09}]█#[bg=#${colors.base09},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{floating_indicator}#[bg=#${colors.base03},fg=#${colors.base02},bold]█"
                        tab_active_fullscreen   "#[bg=#${colors.base03},fg=#${colors.base09}]█#[bg=#${colors.base09},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{fullscreen_indicator}#[bg=#${colors.base03},fg=#${colors.base02},bold]█"
                        tab_active_sync         "#[bg=#${colors.base03},fg=#${colors.base09}]█#[bg=#${colors.base09},fg=#${colors.base02},bold]{index} #[bg=#${colors.base02},fg=#${colors.base05},bold] {name}{sync_indicator}#[bg=#${colors.base03},fg=#${colors.base02},bold]█"

                        // separator between the tabs
                        tab_separator           "#[bg=#${colors.base00}] "

                        // indicators
                        tab_sync_indicator       " "
                        tab_fullscreen_indicator " 󰊓"
                        tab_floating_indicator   " 󰹙"

                        command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                        command_git_branch_format      "#[fg=blue] {stdout} "
                        command_git_branch_interval    "10"
                        command_git_branch_rendermode  "static"

                        datetime        "#[fg=#6C7086,bold] {format} "
                        datetime_format "%A, %d %b %Y %H:%M"
                        datetime_timezone "Europe/Berlin"
                    }
                }
                children
            }
        }
      '';
    };
  };
}
