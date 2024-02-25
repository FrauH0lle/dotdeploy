# Paths
# Discard duplicates from $VARs
typeset -gU cdpath fpath FPATH mailpath path PATH
path=( $XDG_BIN_HOME $path )
fpath=( $ZDOTDIR/functions $XDG_BIN_HOME $fpath )

# Load module specific environments
#
## Custom settings
[[ -f $HOME/.commonrc ]] && source "$HOME/.commonrc"

IS_BASH="false"
IS_ZSH="true"

# Environment
[[ -f $HOME/.env.sh ]] && source "$HOME/.env.sh"
