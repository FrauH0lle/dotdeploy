# -*- mode: sh; -*-

# Based on gnzh theme

setopt prompt_subst

git_prompt_info () {
  local ref
  if [[ "$(__git_prompt_git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]
  then
    ref=$(__git_prompt_git symbolic-ref HEAD 2> /dev/null)  || ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null)  || return 0
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(parse_git_dirty)${ref#refs/heads/}$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

() {

local PR_USER PR_PROMPT PR_HOST

ENDCHAR="λ"
if [ "$UID" = "0" ]; then
    ENDCHAR="#"
fi

FG="#5fd7ff"
BG="#8a8a8a"
AT="#8a8a8a"
HCOLOR="#ff5fd7"

# Check the UID
if [[ $UID -ne 0 ]]; then # normal user
  PR_USER='%F{$FG%}%n%f'
  PR_PROMPT='%f➤ %B$ENDCHAR%b%f'
else # root
  PR_USER='%F{red}%n%f'
  PR_PROMPT='%F{red}➤ %B$ENDCHAR%b%f'
fi

# Check if we are on SSH or not
if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
  PR_HOST='%F{red}%M%f' # SSH
else
  PR_HOST='%F{$HCOLOR}%M%f' # no SSH
fi


local return_code="%(?..%F{red}%? ↵%f)"

local user_host="${PR_USER}%F{$AT}@${PR_HOST}"
local current_dir="%B%F{$BG%}%(5~|%-1~/…/%3~|%4~)%f%b"
local git_branch='$(git_prompt_info)'

PROMPT="╭─${user_host} ${current_dir}\$(git_prompt_info)
╰─$PR_PROMPT "
RPROMPT="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX=" %F{$FG%}git:(%f"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{$FG%})%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}"

}
