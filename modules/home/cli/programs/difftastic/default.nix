{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.flocke;
let
  cfg = config.cli.programs.difftastic;

  # Options are folded into the command string rather than set via
  # programs.difftastic.options: home-manager only renders those into the
  # diff.external / difftool integration, which is deliberately not used here.
  difftOptions = concatStringsSep " " (mapAttrsToList (n: v: "--${n} ${toString v}") cfg.options);
  difft = concatStringsSep " " (
    [ (getExe pkgs.difftastic) ] ++ optional (difftOptions != "") difftOptions
  );
in
{
  options.cli.programs.difftastic = with types; {
    enable = mkBoolOpt false "Whether or not to enable difftastic";
    options = mkOpt (attrsOf (either str int)) {
      context = 7;
    } "Command line options passed to difft. See `difft --help`";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.difftastic ];

    # https://difftastic.wilfred.me.uk/git.html
    programs.git.iniContent = {
      # `git show` and `git log` ignore diff.external unless passed --ext-diff,
      # so they keep rendering through delta until one of these aliases is used.
      alias = {
        dshow = "-c 'diff.external=${difft}' show --ext-diff";
        dlog = "-c 'diff.external=${difft}' log -p --ext-diff";
      };

      # Note this makes git silently ignore --word-diff, which cannot be
      # honoured once diff generation is handed to an external driver.
      diff.external = difft;
      diff.tool = "difftastic";
      difftool = {
        prompt = false;
        # The seven positional args make difft report the real path instead of
        # the temporary checkout it is handed.
        difftastic.cmd = ''${difft} "$MERGED" "$LOCAL" "abcdef1" "100644" "$REMOTE" "abcdef2" "100644"'';
      };
      pager.difftool = true;
    };
  };
}
