#!/usr/bin/env bash

# Short-circuit if common.sh has already been sourced
[[ $(type -t dd::common::loaded) == function ]] && return 0


source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/log.sh

DOTDEPLOY_VERSION="0.1.1"

# Detect if a program is installed
# Arguments:
#   $1 - Name of the program to check
# Outputs:
#   None. Exit status should be used.
dd::common::check_callable() {
    command -v "$1" >/dev/null
}

# Detect if a program is not installed
# Arguments:
#   $1 - Name of the program to check
# Outputs:
#   None. Exit status should be used.
dd::common::check_uncallable() {
    ! command -v "$1" >/dev/null
}

# Detect Linux distribution
# Arguments:
#   None
# Outputs:
#   Linux distribution ID string or "unknown".
dd::common::detect_os() {
    local os_id="unknown"
    # /etc/os-release should be always present in distribution using systemd
    if [[ -f /etc/os-release ]]; then
        os_id=$(grep "^ID=" /etc/os-release | cut -d'=' -f2)
        echo "$os_id"
    else
        dd::log::log-fail "'/etc/os-release' not found."
        echo "$os_id"
    fi
}

# Detect if we are in a container
# Arguments:
#   None
# Outputs:
#   "true" if in a container, else "fale".
dd::common::detect_container() {
    local is_container="false"
    if [[ -f /run/.containerenv || -f /.dockerenv || -n "${container:-}" ]]; then
        is_container="true"
    fi
    echo "$is_container"
}

# Detect host name
# Arguments:
#   None
# Outputs:
#   Host name or "unknown"
dd::common::detect_host() {
    local host_name="unknown"
    if [[ -f /etc/hostname ]]; then
        host_name=$(cat /etc/hostname)
        echo "$host_name"
    elif dd::common::check_callable hostname; then
        host_name=$(hostname)
        echo "$host_name"
    else
        dd::log::log-fail "Could not detect host name."
        echo "$host_name"
    fi
}

# Ensure git repository is cloned
# Arguments:
#   $1 - Valid git repository URL
#   $2 - Target folder
# Outputs:
#   None. Clones git repository if necessary.
dd::common::ensure_repo() {
    local repo="$1"
    local target="$2"
    if [[ ! -d $target ]]; then
        dd::common::dry_run git clone --recursive "$repo" "$target"
    else
        dd::log::log-info "$repo already present"
    fi
}

# Run with sudo and prevent timeout
# Warning: Do not use with redirection!
# Arguments:
#   $@ - Command to run with sudo privileges
# Env:
#   $dryrun
# Outputs:
#   Runs the command with elevated priviliges
dd::common::elevate_cmd() {
    local cmd=( "$@" )
    if [[ "$dryrun" -eq 1 ]]; then
        dd::log::log-info "${cmd[@]}" >&2
    else
        # Ask for sudo password up-front
        sudo -v
        while true; do
            # Update user's timestamp without running a command
            sudo -nv; sleep 1m
            # Exit when the parent process is not running any more. In fact this
            # loop would be killed anyway after being an orphan (when the parent
            # process exits). But this ensures that and probably exit sooner.
            kill -0 $$ 2>/dev/null || exit
        done &
        # Run command
        sudo "${cmd[@]}" || exit 1
    fi
}

# Execute or print command
# Warning: Do not use with redirection!
# Arguments:
#   $@ - Command to run or print
# Env:
#   $dryrun
# Outputs:
#   Runs or prints the command.
# Based on https://stackoverflow.com/a/50003418/22738667
dd::common::dry_run() {
    if [[ "$dryrun" -eq 1 ]]; then
        if [[ ! -t 0 ]]; then
            # Read from stdin if data is being piped
            cat
        fi
        # Safely format the command string
        printf -v cmd_str '%q ' "$@"
        # Print the command
        dd::log::log-info "$cmd_str" >&2
    else
        # Execute the command
        "$@" || exit 1
    fi
}

# Execute or print jq command
# Last argument HAS to be the jq database filename.
# Arguments:
#   $@ - Command to run or print
# Env:
#   $dryrun
# Outputs:
#   Runs or prints the jq command.
# Based on https://stackoverflow.com/a/50003418/22738667
dd::common::jq_dry_run() {
    # Split the input args
    local args=( "$@" )
    local len="${#args[@]}"
    local db_file="${args[$len-1]}"
    local args=( "${args[@]:0:$len-1}" )

    if [[ "$dryrun" -eq 1 ]]; then
        if [[ ! -t 0 ]]; then
            # Read from stdin if data is being piped
            cat
        fi
        # Safely format the command string
        printf -v cmd_str '%q ' "${args[*]} $db_file"
        # Print the command
        dd::log::log-info "$cmd_str" >&2
    else
        # Execute the command
        "${args[@]}" "$db_file" > "${db_file}.tmp" && mv "${db_file}.tmp" "$db_file" || exit 1
    fi
}

# Ensures that required dependencies are installed
# Arguments:
#   None
# Env:
#   $dryrun
#   $host_os
# Outputs:
#   None or a message
dd::common::ensure_deps() {
    # git
    if ! command -v git >/dev/null; then
        git_cmd=false
    else
        git_cmd=true
    fi
    # jq
    if ! command -v jq >/dev/null; then
        jq_cmd=false
    else
        jq_cmd=true
    fi

    if [ "$git_cmd" = false ] || [ "$jq_cmd" = false ]; then
        dd::log::log-info "Trying to install missing dependencies ..."
        case "$host_os" in
            gentoo)
                if dd::common::check_uncallable equery; then
                    dd::common::elevate_cmd emerge --oneshot --verbose app-portage/gentoolkit || exit 1
                fi
                dd::common::elevate_cmd emerge --oneshot --verbose app-misc/jq dev-vcs/git || exit 1
                ;;
        esac
    fi
}


# Selectively import variables from file.
# Variables are assigned to global scope! Use unset afterwards to clean up.
# Arguments:
#   $1 - File
#   $@ - Variables to import
# Outputs:
#   None
dd::common::import_vars() {
    local file="$1"
    shift
    local vars=( "$@" )
    local declaration

    local var_name
    for var_name in "${vars[@]}"; do
        declaration=$(source "$file" && [[ -v "$var_name" ]] && declare -p "$var_name" || return 0)
        if [[ -n "$declaration" ]]; then
            declaration="${declaration/declare/declare -g}"
            source <(echo "$declaration")
        else
            dd::log::log-warn "Variable '$var_name' not found in '$file'"
        fi
    done
}

dd::common::arr_remove_duplicates() {
    local arr=( "$@" )
    # Associative array to track seen elements
    declare -A seen
    # Array to hold unique elements
    local unique_arr=()

    for elem in "${arr[@]}"; do
        # Because of 'nounset', we need to write it like below
        if [[ -z ${seen[$elem]+"${seen[$elem]}"} ]]; then
            # Add element if not seen before
            unique_arr+=( "$elem" )
            # Mark element as seen
            seen[$elem]=1
        fi
    done

    # Return the unique array
    echo -n "${unique_arr[@]}"
}


#
## Packages

# Create array to be populated by dd::common::register_pkgs. Thus, all packages
# can be installed in one go.
export DOTDEPLOY_REQ_PKGS=()

# Register packages
# Arguments:
#   $@ - Packages to install
# Env:
#   $DOTDEPLOY_REQ_PKGS
# Outputs:
#   None
dd::common::register_pkgs() {
    DOTDEPLOY_REQ_PKGS+=( "$@" )
}

# Install packages
# Arguments:
#   None
# Env:
#   $host_os
#   $DOTDEPLOY_REQ_PKGS
# Outputs:
#   None
dd::common::install_pkgs() {
    case "$host_os" in
        gentoo)
            # --changed-use will rebuild the a package if its USE flags have
            # changed. Otherwise it won't reinstall it.
            # --deep also includes dependencies.
            dd::common::elevate_cmd emerge --verbose --changed-use --deep "${DOTDEPLOY_REQ_PKGS[@]}" || exit 1
            ;;
        ubuntu)
            dd::common::elevate_cmd apt-get install -y "${DOTDEPLOY_REQ_PKGS[@]}" || exit 1
    esac
}

# Marker function to indicate common.sh has been fully sourced
dd::common::loaded() {
  return 0
}
