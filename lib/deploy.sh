#!/usr/bin/env bash

# Short-circuit if deploy.sh has already been sourced
[[ $(type -t dd::deploy::loaded) == function ]] && return 0


# Expected system env variables:
# HOME

# Expected dotdeploy env variables:
# dd_host_name
# dd_distro
# dd_is_container


#
## Libraries
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/env.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/common.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/db.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/log.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/hooks.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/files.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/confgen.sh


# Print usage to stdout.
# Arguments:
#   None
# Outputs:
#   Print usage with examples.
dd::deploy::help() {
    cat <<EOF
Deploy modules to system.

Usage:

    dotdeploy deploy [options] [<module1> <module2> ...]

The host name and the OS will be autodetected if --host and/or --host-os are not
specified.

If modules are not given, they will be read from the host init file.

Options:
    help, -h, --help     Show this help message
    --host               Set hostname
    --distro             Set distribution
EOF
}


# Deploy modules to system
# Arguments:
#   $@ Multiple modules
# Env:
#   $dd_host_name
#   $dd_distro
#   $found_files
#   $all_module_files
#   $DOTDEPLOY_REQ_PKGS
# Outputs:
#   None. Will create symlinks and copy files
dd::deploy::deploy() {
    local modules=()
    while (( $# > 0 )) ; do
        case $1 in
            help | --help | -h)
                # Deactivate logging
                dd::log::log_off
                dd::deploy::help
                exit 0
                ;;
            --host)
                shift # past argument
                dd_host_name="$1"
                ;;
            --distro)
                shift # past argument
                dd_distro="$1"
                ;;
            --)
                shift
                break
                ;;
            -*)
                printf >&2 "Error: Unknown option %s\n" "$1"
                dd::log::log_off
                dd::deploy::help
                exit 1
                ;;
            *)  # Default case: Store arguments in modules arrary
                modules+=( "$1" )
                ;;
        esac
        # Shift to next argument
        shift
    done

    # Check if host name and os are known
    if [[ "$dd_distro" == "unknown" ]]; then
        dd::log::log-fail "Could not determine the distribution."
        dd::log::log-info "You can use the override '--distro'."
        exit 1
    fi

    # Check if dependencies are available and install if necessary
    dd::common::ensure_deps

    # Run host OS setup function
    # This should ensure that things like custom/personal repositories are in
    # place
    source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/prepare.sh

    # We know the the host name and try to find an init file in a directory with
    # the same name. This file defines requested modules.

    local dotdeploy_modules=()

    local host_init_file
    # FIXME Better path
    host_init_file="$DOTDEPLOY_HOSTS_DIR"/"$dd_host_name"/_init

    local install_reason="unknown"
    # If modules are given as arguments, these will be installed. Otherwise,
    # look for the host init.
    if [[ ${#modules[@]} -eq 0 ]]; then
        # Abort if no modules are specified in the CMD arguments and no host
        # init file could be found.
        if [[ ! -f "$host_init_file" ]]; then
            dd::log::log-fail "No modules specified and no host specification found."
            exit 1
        else
            # Assign host module
            dotdeploy_modules+=( hosts/"$dd_host_name" )
            install_reason="auto"
        fi
    else
        dotdeploy_modules+=( "${modules[@]}" )
        install_reason="manual"
    fi

    # Remove any duplicates in dotdeploy_modules
    mapfile -t dotdeploy_modules < <(dd::common::arr_remove_duplicates "${dotdeploy_modules[@]}")

    # Function to recursively resolve dependencies
    # FIXME Move to better section
    resolve_dependencies() {
        local module="$1"
        if [[ "$module" == "hosts/"* ]]; then
            local module_file="$DOTDEPLOY_ROOT"/"$module/"_init
        else
            local module_file="$DOTDEPLOY_MODULES_DIR/$module/"_init
        fi
        dd::common::import_vars "$module_file" depends
        for dep in "${depends[@]}"; do
            if ! [[ " ${resolved_deps[*]} " =~ $dep ]]; then
                resolved_deps+=("$dep")
                resolve_dependencies "$dep"
            fi
        done
    }
    # Initialize an array to hold all resolved dependencies
    local resolved_deps=()

    # Main loop to resolve dependencies for each module
    unset -v depends
    local module
    for module in "${dotdeploy_modules[@]}"; do
        resolve_dependencies "$module"
        unset -v depends
    done

    # Filter dependencies
    if [[ "${#resolved_deps[@]}" -gt 0 ]]; then
        local index
        for index in "${!resolved_deps[@]}"; do
            local module
            for module in "${dotdeploy_modules[@]}"; do
                [[ ${resolved_deps[$index]} == "$module" ]] && unset -v 'resolved_deps[$index]'
            done
        done

        resolved_deps=( "${resolved_deps[@]}" )
        dd::log::log-info "The following modules have been added as dependencies:"
        local dep
        for dep in "${resolved_deps[@]}"; do
            dd::log::log-info "    - $dep"
        done
    fi

    dotdeploy_modules=( "${resolved_deps[@]}" "${dotdeploy_modules[@]}" )

    # Verify that all deployed files are still valid
    local module
    for module in "${dotdeploy_modules[@]}"; do
        dd::files::remove_missing "$module"
    done

    local key
    for key in "${!missing_sys_files[@]}"; do
        IFS='|' read -r module source <<< "$key"
        echo "${missing_sys_files[$key]} misses $source"
        dd::db::delete_file "$DOTDEPLOY_DB" "$module" "$source"
        dd::common::elevate_cmd rm -fv "${missing_sys_files[$key]}"
    done

    local key
    for key in "${!missing_home_files[@]}"; do
        IFS='|' read -r module source <<< "$key"
        echo "${missing_home_files[$key]} misses $source"
        dd::db::delete_file "$DOTDEPLOY_LOCAL_DB" "$module" "$source"
        dd::common::dry_run rm -fv "${missing_home_files[$key]}"
    done

    # Gather all information from the module declarations.
    dd::hooks::get_all_hooks "${dotdeploy_modules[@]}"
    dd::files::get_all_files "${dotdeploy_modules[@]}"
    dd::files::check_prefix "${found_files[@]}"
    dd::files::assign_files "${all_module_files[@]}"

    # Loop over the phases and steps and execute tasks.
    phases=( "setup" "deploy" "configure" )
    steps=( "pre" "main" "post" )

    # Verify that copied files are not changed
    local changed_files=()
    local phase
    for phase in "${phases[@]}"; do
        local array_name
        for array_name in system_copy home_copy; do
            local -n array_ref="${phase}_${array_name}"
            local key
            for key in "${!array_ref[@]}"; do
                # Separate module from source file path
                IFS='|' read -r m source <<< "$key"
                if [[ $array_name == "system_copy" ]]; then
                    local db_file="$DOTDEPLOY_DB"
                else
                    local db_file="$DOTDEPLOY_LOCAL_DB"
                fi
                local target="${array_ref[$key]}"
                if dd::db::check_source_file "$m" "$source" "$db_file"; then
                    local db_checksum
                    db_checksum=$(dd::db::get_checksum "$db_file" "$m" "$source")
                    local target_checksum
                    if [[ -f $target ]]; then
                        target_checksum=$(sha256sum "$target" | cut -d ' ' -f 1)
                    else
                        target_checksum="not_found"
                    fi
                    if [[ $target_checksum == "not_found" ]]; then
                        dd::log::log-warn "$target was not found."
                    elif [[ $target_checksum != "$db_checksum" ]]; then
                        changed_files+=( "$target" )
                    fi
                fi
            done
        done
    done

    # Give the user a last chance to abort.
    printf "\r\033[2K\033[1;33m%s\033[0m\n" "You are about to deploy the following modules:"
    local module
    for module in "${dotdeploy_modules[@]}"; do
        printf "\r\t - %s\n" "$module"
    done
    seconds=10

    if [[ "${#changed_files[@]}" -gt 0 ]]; then
        printf "\r\033[2K\033[1;31m%s\033[0m\n" "WARNING! The following files have changed locally:"
        local file
        for file in "${changed_files[@]}"; do
            printf "\r\t - %s\n" "$file"
        done
        printf "\r\033[2K\033[1;31m%s\033[0m\n" "Any changes will be overwritten!"
        printf "\r\033[2K\033[1;37m%s\033[0m\n" "Run dotdeploy check to view the changes."
        seconds=30
    fi

    printf "\r\033[2K\033[1;33m\n%s\033[0m\n" "Press Ctrl+C to abort or Enter to continue immediately."

    while [[ "$seconds" -gt 0 ]]; do
        # Print the countdown
        echo -n "$seconds... "

        if read -r -t 1 -s
        then
            echo "Continuing immediately!"
            break
        else
            ((seconds--))
        fi
    done

    local phase
    for phase in "${phases[@]}"; do
        # Translate phase into a descriptive string
        case $phase in
            "deploy")
                phase_desc="deployment"
                ;;
            "configure")
                phase_desc="configuration"
                ;;
            *)
                phase_desc="$phase"
                ;;
        esac

        dd::log::log-info "PHASE: MODULE ${phase_desc^^}"
        local step
        for step in "${steps[@]}"; do
            case $step in
                "main")
                    step_prefix=""
                    ;;
                *)
                    step_prefix="${step}_"
                    ;;
            esac

            if [[ $step == "main" ]]; then
                dd::files::process_phase_files "${phase}"_system_link "link" "system"
                dd::files::process_phase_files "${phase}"_system_copy "copy" "system"
                dd::files::process_phase_files "${phase}"_home_link "link" "user"
                dd::files::process_phase_files "${phase}"_home_copy "copy" "user"

                if [[ $phase == "deploy" ]]; then
                    # Install packages
                    # Collect packages from modules
                    local module
                    for module in "${dotdeploy_modules[@]}"; do
                        local module_init_file
                        # FIXME
                        if [[ "$module" == "hosts/"* ]]; then
                            module_init_file="$DOTDEPLOY_ROOT"/"$module/"_init
                        else
                            module_init_file="$DOTDEPLOY_MODULES_DIR/$module/"_init
                        fi
                        echo ""
                        echo "importing packages for $module"
                        dd::common::import_vars "$module_init_file" packages
                        if [[ -n ${packages+x} ]]; then
                            dd::common::register_pkgs "${packages[@]}"
                        fi
                        unset -v packages
                    done
                    dd::log::log-info "The following packages will be installed:"
                    local pkg
                    for pkg in "${DOTDEPLOY_REQ_PKGS[@]}"; do
                        dd::log::log-info "    - $pkg"
                    done

                    # Execute installation
                    dd::common::install_pkgs
                fi
            fi

            if [[ -f "${tempfiles[${step_prefix}module_${phase}_fns_tmpfile]}" && -s "${tempfiles[${step_prefix}module_${phase}_fns_tmpfile]}" ]]; then
                dd::log::log-info "Running ${step_prefix/_/-}${phase_desc} functions"
                source "${tempfiles[${step_prefix}module_${phase}_fns_tmpfile]}"
                declare -n array_ref="${step_prefix}module_${phase}_fns"
                local i
                for i in "${!array_ref[@]}"; do
                    dd::log::log-info "Executing ${array_ref[$i]}"
                    dd::common::dry_run "${array_ref[$i]}"
                done
            fi

        done
    done

    # If we reached this part without error, we can write the metadata
    local module
    for module in "${dotdeploy_modules[@]}"; do
        for db in "$DOTDEPLOY_DB" "$DOTDEPLOY_LOCAL_DB"; do
            dd::db::write_module_kv "$db" "$module" deployed true
            dd::db::write_module_kv "$db" "$module" last_deployed \""$(date +%F)"\"
            if [[ $install_reason == "auto" ]]; then
                dd::db::write_module_kv_maybe "$db" "$module" reason \""$install_reason"\"
            elif [[ $install_reason == "manual" ]]; then
                dd::db::write_module_kv "$db" "$module" reason \""$install_reason"\"
            fi
        done
    done
    for db in "$DOTDEPLOY_DB" "$DOTDEPLOY_LOCAL_DB"; do
        dd::db::write_meta_kv "$db" version \""$DOTDEPLOY_VERSION"\"
        dd::db::write_meta_kv "$db" hostname \""$dd_host_name"\"
        dd::db::write_meta_kv "$db" linux_distribution \""$dd_distro"\"
    done

    # Generate config files
    dd::confgen::generate env.sh
    dd::confgen::generate fzf.sh
    dd::confgen::generate aliases.sh
    dd::confgen::generate completions.sh

    # Show message collected
    dd::log::display_messages
}


# Marker function to indicate deploy.sh has been fully sourced
dd::deploy::loaded() {
  return 0
}
