# Listing files
# alias ll='eza --long --header --git --group --all -F --group-directories-first'
# alias la='eza --all --group-directories-first'
# alias l='eza -F --group-directories-first'
# alias ldir='eza -1dF */'

alias ls='ls --color=auto'
alias ll='ls -halF --group-directories-first'
alias la='ls -A --group-directories-first'
alias l='ls -CF --group-directories-first'
alias ldir='ls -1d */'

# Enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
