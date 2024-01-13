##%% [[ "$dd_distro" == "gentoo" ]]
if [ "$IS_ZSH" = "true" ]; then
    source /usr/share/zsh/site-functions/_fzf
    source /usr/share/fzf/key-bindings.zsh
fi

if [ "$IS_BASH" = "true" ]; then
    source /usr/share/bash-completion/completions/fzf
    source /usr/share/fzf/key-bindings.bash
fi
##%% end
##%% [[ "$dd_distro" == "ubuntu" ]]
if [ "$IS_ZSH" = "true" ]; then
    source /usr/share/doc/fzf/examples/completion.zsh
    source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

if [ "$IS_BASH" = "true" ]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash
fi
##%% end

##%% [[ "$dd_distro" == "gentoo" ]]
export FZF_DEFAULT_COMMAND='fd -H -I'
##%% end
##%% [[ "$dd_distro" == "ubuntu" ]]
export FZF_DEFAULT_COMMAND='fdfind -H -I'
##%% end
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
##%% [[ "$dd_distro" == "gentoo" ]]
export FZF_CTRL_T_OPTS="--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'"
##%% end
##%% [[ "$dd_distro" == "ubuntu" ]]
export FZF_CTRL_T_OPTS="--preview '([[ -f {} ]] && (batcat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'"
##%% end
##%% [[ "$dd_distro" == "gentoo" ]]
export FZF_ALT_C_COMMAND='fd -H -I --type d'
##%% end
##%% [[ "$dd_distro" == "ubuntu" ]]
export FZF_ALT_C_COMMAND='fdfind -H -I --type d'
##%% end
##%% [[ "$dd_distro" == "gentoo" ]]
export FZF_ALT_C_OPTS="--preview 'eza --long --tree --level=1 --color=auto --icons=auto --group-directories-first -- {}'"
##%% end
##%% [[ "$dd_distro" == "ubuntu" ]]
export FZF_ALT_C_OPTS="--preview 'exa --long --tree --level=1 --color=auto --icons --group-directories-first -- {}'"
##%% end
