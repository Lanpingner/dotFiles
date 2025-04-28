if status is-interactive
    # Commands to run in interactive sessions can go here
end

source ~/.aliasesrc
source ~/.exportsrc
colorscript random
starship init fish | source
zoxide init fish | source
direnv hook fish | source

set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME
set -gx PATH $HOME/.cabal/bin $PATH /home/romeo/.ghcup/bin
set -g direnv_fish_mode eval_on_arrow # trigger direnv at prompt, and on every arrow-based directory change (default)
set -g direnv_fish_mode eval_after_arrow # trigger direnv at prompt, and only after arrow-based directory changes before executing command
set -g direnv_fish_mode disable_arrow # trigger direnv at prompt only, this is similar functionality to the original behavior
