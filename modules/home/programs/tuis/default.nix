{ config
, pkgs
, lib
, ...
}:
with lib;
let
  cfg = config.programs.tuis;
in
{
  options.programs.tuis = {
    enable = mkEnableOption "Enable TUI applications";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      with pkgs.flocke;
      [
        s-tui
        mc
      ];

    xdg.dataFile."mc/skins/catppuccin.ini".text = ''
      [skin]
          description = Catppuccin

      [Lines]
          horiz = ─
          vert = │
          lefttop = ╭
          righttop = ╮
          leftbottom = ╰
          rightbottom = ╯
          topmiddle = ┬
          bottommiddle = ┴
          leftmiddle = ├
          rightmiddle = ┤
          cross = ┼
          dhoriz = ─
          dvert = │
          dlefttop = ╭
          drighttop = ╮
          dleftbottom = ╰
          drightbottom = ╯
          dtopmiddle = ┬
          dbottommiddle = ┴
          dleftmiddle = ├
          drightmiddle = ┤

      [filehighlight]
          directory = blue;
          executable = red;
          symlink = cyan;
          hardlink = cyan;
          stalelink = cyan;
          device = brightgreen;
          special = green;
          core = red;
          temp = brightgreen;
          archive = red;
          doc = yellow;
          source = brightcyan;
          media = brightgreen;
          graph = cyan;
          database = brightred;

      [core]
          _default_ = magenta;default
          selected = black;cyan
          marked = black;cyan
          markselect = black;blue
          gauge = black;magenta
          input = blue;black
          inputmark = black;red
          inputunchanged = red;black
          commandlinemark = white;red
          reverse = black;magenta
          header = black;magenta

      [dialog]
          _default_ = magenta;gray
          dfocus = black;magenta
          dhotnormal = gray;magenta
          dhotfocus = gray;magenta
          dtitle = magenta;gray

      [error]
          _default_ = red;gray
          errdfocus = black;red
          errdhotnormal = red;black
          errdhotfocus = yellow;red
          errdtitle = gray;red

      [menu]
          _default_ = white;black
          menusel = black;cyan
          menuhot = black;cyan
          menuhotsel = cyan;black
          menuinactive = white;black

      [help]
          _default_ = magenta;gray
          helpitalic = red;black;italic
          helpbold = brightgreen;black;bold
          helplink = blue;black
          helpslink = gray;blue
          helptitle = gray;magenta

      [editor]
          _default_ = magenta;default
          editbold = brightgreen;black
          editmarked = black;cyan
          editwhitespace = brightblue;black
          editlinestate = white;black
          bookmark = black;red
          bookmarkfound = black;brightgreen
          editrightmargin = brightblue;black
          editframe = brightgreen;
          editframeactive = white;
          editframedrag = brightblue;

      [viewer]
          _default_ = magenta;default
          viewbold = green;black;bold
          viewunderline = red;black
          viewselected = blue;black

      [popupmenu]
          _default_ = white;black
          menusel = black;cyan
          menutitle = white;black

      [buttonbar]
          hotkey = black;cyan
          button = white;black

      [statusbar]
          _default_ = white;black

      [diffviewer]
          added = black;green
          changedline = black;cyan
          changednew = red;cyan
          changed = black;yellow
          removed = black;red
          error = red;white

      [widget-common]
          sort-sign-up = ↑
          sort-sign-down = ↓

      [widget-panel]
          hiddenfiles-sign-show = •
          hiddenfiles-sign-hide = ○
          history-prev-item-sign = «
          history-next-item-sign = »
          history-show-list-sign = ^
          filename-scroll-left-char = «
          filename-scroll-right-char = »

      [widget-editor]
          window-state-char = ↕
          window-close-char = ✕
    '';
  };
}
