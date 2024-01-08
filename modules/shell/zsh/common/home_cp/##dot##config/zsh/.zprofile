# Paths
# Discard duplicates from $VARs
typeset -gU cdpath fpath FPATH mailpath path PATH
path=( $XDG_BIN_HOME $path )
fpath=( $ZDOTDIR/functions $XDG_BIN_HOME $fpath )

# Load module specific environments
_load_all env.zsh
