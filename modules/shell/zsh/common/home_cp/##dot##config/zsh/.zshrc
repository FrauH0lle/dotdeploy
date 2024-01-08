#
## Powerlevel10k instant prompt

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


#
## Zinit initialization

### Added by Zinit's installer
if [[ ! -f $HOME/.config/zsh/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.config/zsh/.zinit" && command chmod g-rwX "$HOME/.config/zsh/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.config/zsh/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.config/zsh/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node

### End of Zinit's installer chunk


#
## Core configuration

#Load the prompt system and completion system and initilize them.
autoload -Uz compinit promptinit


#
## Theme

# Most Themes Use This Option.
setopt promptsubst

# provide a simple prompt till the theme loads
PS1="READY >"

# P10k
zinit ice wait'!' lucid
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Set correct $TERM variable for Emacs Tramp
[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return


#
## Plugins

# oh-my-zsh, all of them
zinit ice svn multisrc"*.zsh" as"null"
zinit snippet OMZ::lib

# OMZ::history.zsh
# share command history data
setopt share_history
# Increase history size
HISTSIZE=1000000000
SAVEHIST=1000000000

# z.sh
zinit ice wait'0a' lucid
zinit light rupa/z
if [[ ! -f ~/.z ]]; then
    touch ~/.z
fi

# zsh-completions
zinit ice wait'0a' lucid blockf
zinit light zsh-users/zsh-completions

# zsh-autosuggestions
zinit ice wait'0a' lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

# zsh-autopair
zinit ice wait'0a' lucid
zinit light hlissner/zsh-autopair

# fast-syntax-highlighting
zinit ice wait'0b' lucid
zinit light zdharma-continuum/fast-syntax-highlighting

# zsh-history-substring-search
zinit ice wait'0b' lucid
zinit light zsh-users/zsh-history-substring-search


#
## Programms

zinit ice from"gh-r" as"program" mv"tealdeer-* -> tldr"
zinit light dbrgn/tealdeer
zinit ice wait'1' lucid as"completion" mv'zsh_tealdeer -> _tldr'
zinit snippet https://github.com/dbrgn/tealdeer/blob/main/completion/zsh_tealdeer


#
## Direnv

# Hook up direnv, if available
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi


#
## Base16 Shell

BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        source "$BASE16_SHELL/profile_helper.sh"


#
## Custom settings
[[ -f $HOME/.commonrc ]] && source "$HOME/.commonrc"

IS_BASH="false"
IS_ZSH="true"

# Environment
[[ -f $HOME/.env.sh ]] && source "$HOME/.env.sh"

# fzf
[[ -f $HOME/.fzf.sh ]] && source "$HOME/.fzf.sh"

# Aliases
[[ -f $HOME/.aliases.sh ]] && source "$HOME/.aliases.sh"


#
## Bash completions
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit
[[ -f $HOME/.completions.sh ]] && source "$HOME/.completions.sh"


#
## Powerlevel10k customization

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
# Switch prompt if we are in TTY
if [[ `tput colors` != "256" ]]; then
    [[ ! -f ~/.config/zsh/.p10k-tty.zsh ]] || source ~/.config/zsh/.p10k-tty.zsh
else
    [[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
fi


#
## Local settings
[[ ! -f ~/.config/zsh/.zshrc.local ]] || source ~/.config/zsh/.zshrc.local
