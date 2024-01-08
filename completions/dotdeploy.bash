#!/usr/bin/env bash

file_path=$(dirname "$(which dotdeploy)")

_dotdeploy_completions() {
    # Main commands
    local options_main="deploy help -h --help"

    local current_word="${COMP_WORDS[COMP_CWORD]}"
    local previous_word="${COMP_WORDS[COMP_CWORD - 1]}"

    # Complete only the first argument with commands or options
    if [[ "${COMP_CWORD}" == 1 ]]; then
        COMPREPLY=($(compgen -W "$options_main" -- "${COMP_WORDS[1]}"))
        # If the first argument is 'deploy', provide module completions
    elif [[ "${COMP_WORDS[*]:0:$COMP_CWORD}" =~ "deploy" ]]; then
        # Construct a regex pattern of options to exclude from the list of module names
        local exclude_pattern
        for word in "${COMP_WORDS[@]:1:$COMP_CWORD-1}"; do
            if [[ "$word" != -* ]]; then
                exclude_pattern+="\b$word\b|"
            fi
        done
        exclude_pattern=${exclude_pattern%|}  # Remove the trailing pipe
        local available_modules
        available_modules="$(find "$file_path"/modules/ -type f -name "_init" -exec dirname {} \; | sed 's/.*modules\/\(.*\)/\1/g')"
        # Read the available modules and filter out the already included ones
        if [[ -n "$exclude_pattern" ]]; then
            compreply=($(compgen -W "$available_modules" -- "$current_word" | grep -Ev "$exclude_pattern"))
        else
            compreply=($(compgen -W "$available_modules" -- "$current_word"))
        fi
        COMPREPLY=("${compreply[@]}")
    fi
}

complete -F _dotdeploy_completions dotdeploy
