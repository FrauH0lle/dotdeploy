#!/usr/bin/env bash

# Short-circuit if hooks.sh has already been sourced
[[ $(type -t dd::hooks::loaded) == function ]] && return 0


#
## Libraries
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/env.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/log.sh


declare -a pre_module_setup_fns module_setup_fns post_module_setup_fns
declare -a pre_module_deploy_fns module_deploy_fns post_module_deploy_fns
declare -a pre_module_configure_fns module_configure_fns post_module_configure_fns

declare -A tempfiles

for fname in pre_module_setup_fns_tmpfile module_setup_fns_tmpfile \
    post_module_setup_fns_tmpfile pre_module_deploy_fns_tmpfile \
    module_deploy_fns_tmpfile post_module_deploy_fns_tmpfile \
    pre_module_configure_fns_tmpfile module_configure_fns_tmpfile \
    post_module_configure_fns_tmpfile; do

    tempfiles[$fname]=$(mktemp --tmpdir="$DOTDEPLOY_TMP_DIR" --suffix .sh)
done
unset -v fname

# Gather all phase functions from module init files
# Arguments:
#   $@ - Modules
# Env:
#   $pre_module_setup_fns
#   $module_setup_fns
#   $post_module_setup_fns
#   $pre_module_deploy_fns
#   $module_deploy_fns
#   $post_module_deploy_fns
#   $pre_module_configure_fns
#   $module_configure_fns
#   $post_module_configure_fns
# Outputs:
#   None. Write functions to temporary files and append functions names to
#   arrays.
dd::hooks::get_all_hooks() {
    local modules=( "$@" )

    local module
    for module in "${modules[@]}"; do
        dd::log::log-info "Collect funcs for $module"
        # FIXME
        if [[ "$module" == "hosts/"* ]]; then
            local module_init_file="$DOTDEPLOY_ROOT"/"$module/"_init
        else
            local module_init_file="$DOTDEPLOY_MODULES_DIR/$module/"_init
        fi

        source "$module_init_file"

        local phase
        for phase in pre_module_setup module_setup post_module_setup \
            pre_module_deploy module_deploy post_module_deploy \
            pre_module_configure module_configure post_module_configure; do

            if declare -f "$phase" > /dev/null; then
                local func_def
                func_def=$(declare -f $phase)
                # Replace all "/" with "_"
                local new_name="${phase}_${module//\//_}"
                func_def="${func_def/$phase/$new_name}"

                echo "$func_def" >> "${tempfiles["${phase}_fns_tmpfile"]}"

                declare -n array_ref="${phase}_fns"
                array_ref+=( "$new_name" )
                unset -f $phase
            fi
            # Unset the phase variable, otherwise we store leftover functions.
            unset -v $phase
        done
    done
}

# Marker function to indicate hooks.sh has been fully sourced
dd::hooks::loaded() {
  return 0
}
