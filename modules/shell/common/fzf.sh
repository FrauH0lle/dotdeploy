if [ "$IS_ZSH" = "true" ]; then
    source /usr/share/zsh/site-functions/_fzf
    source /usr/share/fzf/key-bindings.zsh
fi

if [ "$IS_BASH" = "true" ]; then
    source /usr/share/bash-completion/completions/fzf
    source /usr/share/fzf/key-bindings.bash
fi

export FZF_DEFAULT_COMMAND='fd -H -I'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'"
export FZF_ALT_C_COMMAND='fd -H -I --type d'
export FZF_ALT_C_OPTS="--preview 'eza --long --tree --level=1 --color=auto --icons=auto --group-directories-first -- {}'"
