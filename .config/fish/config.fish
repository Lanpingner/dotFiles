if status is-interactive
    # Commands to run in interactive sessions can go here
end

source ~/.aliasesrc
source ~/.exportsrc
colorscript random
starship init fish | source
zoxide init fish | source

set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME
set -gx PATH $HOME/.cabal/bin $PATH /home/romeo/.ghcup/bin # ghcup-env
