#!/usr/bin/env bash

# Short-circuit if files.sh has already been sourced
[[ $(type -t dd::files::loaded) == function ]] && return 0


#
## Libraries
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/env.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/common.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/db.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/log.sh


# More globbing
shopt -s extglob

# Global array storing all files from requested modules
declare -a found_files
declare -a all_module_files

# Global arrays storing files which should be deployed in certain stage
declare -A setup_home_copy setup_home_link
declare -A deploy_home_copy deploy_home_link
declare -A configure_home_copy configure_home_link
declare -A setup_system_copy setup_system_link
declare -A deploy_system_copy deploy_system_link
declare -A configure_system_copy configure_system_link

# Gather all files from modules
# Arguments:
#   $@ - Modules
# Env:
#   $found_files
# Outputs:
#   None. Appends to $found_files.
dd::files::get_all_files() {
    local modules=( "$@" )

    local module
    for module in "${modules[@]}"; do
        # FIXME Remove hardcoding
        if [[ "$module" == "hosts/"* ]]; then
            local module_path="$DOTDEPLOY_ROOT"/"$module"
        else
            local module_path="$DOTDEPLOY_MODULES_DIR"/"$module"
        fi
        if [[ -d "$module_path"/common ]]; then
            local common_files
            local temp
            mapfile -t temp < <(find "$module_path"/common -type f)
            local f
            for f in "${temp[@]}"; do
                common_files+=( "$module|$f" )
            done
        fi
        if [[ -d "$module_path/$dd_distro" ]]; then
            local distro_files
            local temp
            mapfile -t temp < <(find "$module_path/$dd_distro" -type f)
            local f
            for f in "${temp[@]}"; do
                distro_files+=( "$module|$f" )
            done
        fi
    done
    found_files+=( "${common_files[@]}" "${distro_files[@]}" )
}

# Transform source file name into target file name
# Arguments:
#   $1 - Source file name
# Env:
#   $dd_distro
#   $HOME
# Outputs:
#   Transformed file name.
dd::files::transform_filename() {
    local fname
    # Split module string from file path
    IFS='|' read -r module fname <<< "$1"
    # Remove the leading path up to and including either 'common/' or a host OS
    # specific folder
    fname="${fname#*"$module"/@(common|"$dd_distro")/}"
    # Remove the first occurrence of 'setup/'
    fname="${fname/setup\//}"
    # Remove the first occurrence of 'configure/'
    fname="${fname/configure\//}"
    # Replace the first occurrence of '##dot##' with '.'
    fname="${fname/\#\#dot\#\#/.}"
    # Replace the first occurrence of 'home_cp/' or 'home_ln/' with the user's
    # home directory
    fname="${fname/home_@(cp|ln)/$HOME}"
    # Remove the first occurrence of 'system_cp/' or 'system_ln/'
    fname="${fname/system_@(cp|ln)/}"
    # Remove everything up to and including the last occurrence of '##' followed
    # by '--'
    fname="${fname/\#\#*--/}"
    echo "$fname"
}

# Extract and evaluate prefix conditons
# Arguments:
#   $1 - File name
# Outputs:
#   "true" if all conditions match, else "false".
dd::files::extract_prefix_info() {
    local filename="$1"
    local prefix_part remaining_prefix key_value_pairs key value

    # Remove everything after the '--' to isolate the prefix part
    prefix_part="${filename%%--*}"
    remaining_prefix="$prefix_part"

    # Remove the leading '##' for cleaner processing
    remaining_prefix="${remaining_prefix##*##}"

    # Initialize an associative array to store key-value pairs
    declare -A key_value_pairs

    # Extract key-value pairs
    while [[ $remaining_prefix =~ \. ]]; do
        key="${remaining_prefix%%.*}"
        remaining_prefix="${remaining_prefix#*.}"
        value="${remaining_prefix%%.*}"
        remaining_prefix="${remaining_prefix#*.}"
        key_value_pairs[$key]="$value"
    done

    # Output the key-value pairs
    local deploy="true"
    local key
    for key in "${!key_value_pairs[@]}"; do
        # echo "$key: ${key_value_pairs[$key]}"
        # Check if key-value pairs match conditions
        if [[ "${key_value_pairs[host]+_}" && "${key_value_pairs[host]}" != "$dd_host_name" ]] ||
               [[ "${key_value_pairs[os]+_}" && "${key_value_pairs[os]}" != "$dd_distro" ]]; then
            deploy="false"
        fi
    done
    echo "$deploy"
}

# Check prefixes of files
# Arguments:
#   $@ - Files
# Env:
#   $all_module_files
# Outputs:
#   None. Append files to 'all_module_files if prefix conditions hold.
dd::files::check_prefix() {
    local files=( "$@" )
    local file
    for file in "${files[@]}"; do
        if [[ $(dd::files::extract_prefix_info "$file") == "true" ]]; then
            all_module_files+=( "$file" )
        fi
    done
}

# Assign files to their phase arrays.
# Arguments:
#   $@ - Files
# Env:
#   $setup_home_copy
#   $setup_home_link
#   $deploy_home_copy
#   $deploy_home_link
#   $configure_home_copy
#   $configure_home_link
#   $setup_system_copy
#   $setup_system_link
#   $deploy_system_copy
#   $deploy_system_link
#   $configure_system_copy
#   $configure_system_link
# Outputs:
#   None. Append files to arrays.
dd::files::assign_files() {
    local files=( "$@" )
    local file
    for file in "${files[@]}"; do
        # Check if pre- and configure
        case $file in
            *home_cp*)
                if [[ $file == *setup* ]]; then
                    setup_home_copy[$file]=$(dd::files::transform_filename "$file")
                elif [[ $file == *configure* ]]; then
                    configure_home_copy[$file]=$(dd::files::transform_filename "$file")
                else
                    deploy_home_copy[$file]=$(dd::files::transform_filename "$file")
                fi
                ;;
            *home_ln*)
                if [[ $file == *setup* ]]; then
                    setup_home_link[$file]=$(dd::files::transform_filename "$file")
                elif [[ $file == *configure* ]]; then
                    configure_home_link[$file]=$(dd::files::transform_filename "$file")
                else
                    deploy_home_link[$file]=$(dd::files::transform_filename "$file")
                fi
                ;;
            *system_cp*)
                if [[ $file == *setup* ]]; then
                    setup_system_copy[$file]=$(dd::files::transform_filename "$file")
                elif [[ $file == *configure* ]]; then
                    configure_system_copy[$file]=$(dd::files::transform_filename "$file")
                else
                    deploy_system_copy[$file]=$(dd::files::transform_filename "$file")
                fi
                ;;
            *system_ln*)
                if [[ $file == *setup* ]]; then
                    setup_system_link[$file]=$(dd::files::transform_filename "$file")
                elif [[ $file == *configure* ]]; then
                    configure_system_link[$file]=$(dd::files::transform_filename "$file")
                else
                    deploy_system_link[$file]=$(dd::files::transform_filename "$file")
                fi
                ;;
            *)
                echo "does not match: $file"
                ;;
        esac
    done
}

# Copy module file
# Arguments:
#   $1 - Database file
#   $2 - Module
#   $3 - Source file path
#   $4 - Target file path
#   $5 - "true" if system file
# Outputs:
#   None.
dd::files::copy_file() {
    local db_file="$1"
    local module="$2"
    local source="$3"
    local target="$4"
    local system="${system:-false}"
    local type="copy"
    local db_checksum
    local checksum

    # Make sure module entry exists in database
    dd::db::ensure-module "$db_file" "$module"

    # Check if file is in database and if yes, get and compare checksums
    checksum=$(sha256sum "$source" | cut -d ' ' -f 1)
    if dd::db::check_source_file "$module" "$source" "$db_file"; then
        db_checksum=$(dd::db::get_checksum "$db_file" "$module" "$source")
        if [[ "$db_checksum" != "$checksum" ]]; then
            # If checksums do not match, deploy the file and add the file to the
            # DB again.
            dd::db::delete_file "$db_file" "$module" "$source"
            dd::db::add_file "$db_file" "$module" "$source" "$target" "$type" "$checksum"
            if [[ "$system" == "true" ]]; then
                dd::common::elevate_cmd cp -v --remove-destination "$source" "$target"
            else
                dd::common::dry_run cp -v --remove-destination "$source" "$target"
            fi
        else
            dd::log::log-ok "Copy of $target is already deployed and up-to-date."
        fi
    else
        # If the file is not present in the DB, deploy and add it.
        if [[ -f "$target" ]]; then
            if [[ "$system" == "true" ]]; then
                dd::files::backup_file "$target" "system"
            else
                dd::files::backup_file "$target"
            fi
        fi
        dd::db::add_file "$db_file" "$module" "$source" "$target" "$type" "$checksum"
        if [[ "$system" == "true" ]]; then
            [[ -d "$(dirname "$target")" ]] || dd::common::elevate_cmd mkdir -p "$(dirname "$target")"
            dd::common::elevate_cmd cp -v --remove-destination "$source" "$target"
        else
            [[ -d "$(dirname "$target")" ]] || dd::common::dry_run mkdir -p "$(dirname "$target")"
            dd::common::dry_run cp -v --remove-destination "$source" "$target"
        fi
    fi
}

# Copy module file to $HOME
# Arguments:
#   $1 - Module
#   $2 - Source file path
#   $3 - Target file path
# Outputs:
#   None.
dd::files::copy_home_file() {
    local module="$1"
    local source="$2"
    local target="$3"
    dd::files::copy_file "$DOTDEPLOY_LOCAL_DB" "$module" "$source" "$target"
}

# Copy module file to /
# Arguments:
#   $1 - Module
#   $2 - Source file path
#   $3 - Target file path
# Outputs:
#   None.
dd::files::copy_sys_file() {
    local module="$1"
    local source="$2"
    local target="$3"
    local system="true"
    dd::files::copy_file "$DOTDEPLOY_DB" "$module" "$source" "$target" "$system"
}

# Link module file
# Arguments:
#   $1 - Database file
#   $2 - Module
#   $3 - Source file path
#   $4 - Target file path
#   $5 - "true" if system file
# Outputs:
#   None.
dd::files::link_file() {
    local db_file="$1"
    local module="$2"
    local source="$3"
    local target="$4"
    local system="${system:-false}"
    local type="link"

    # Make sure module entry exists in database
    dd::db::ensure-module "$db_file" "$module"

    # Check if file is in database and if yes, don't do anything
    if dd::db::check_source_file "$module" "$source" "$db_file"; then
        dd::log::log-ok "Link to $target is already deployed."
    else
        # If the file is not present in the DB, deploy and add it.
        if [[ -f "$target" ]]; then
            if [[ "$system" == "true" ]]; then
                dd::files::backup_file "$target" "system"
            else
                dd::files::backup_file "$target"
            fi
        fi
        dd::db::add_file "$db_file" "$module" "$source" "$target" "$type"
        if [[ "$system" == "true" ]]; then
            [[ -d "$(dirname "$target")" ]] || dd::common::elevate_cmd mkdir -p "$(dirname "$target")"
            dd::common::elevate_cmd ln -sfv "$source" "$target"
        else
            [[ -d "$(dirname "$target")" ]] || dd::common::dry_run mkdir -p "$(dirname "$target")"
            dd::common::dry_run ln -sfv "$source" "$target"
        fi
    fi
}

# Link module file to $HOME
# Arguments:
#   $1 - Module
#   $2 - Source file path
#   $3 - Target file path
# Outputs:
#   None.
dd::files::link_home_file() {
    local module="$1"
    local source="$2"
    local target="$3"
    dd::files::link_file "$DOTDEPLOY_LOCAL_DB" "$module" "$source" "$target"
}

# Link module file to /
# Arguments:
#   $1 - Module
#   $2 - Source file path
#   $3 - Target file path
# Outputs:
#   None.
dd::files::link_sys_file() {
    local module="$1"
    local source="$2"
    local target="$3"
    local system="true"
    dd::files::link_file "$DOTDEPLOY_DB" "$module" "$source" "$target" "$system"
}

# Process phase file array
# Arguments:
#   $1 - Array name
#   $2 - "copy" (default) or "link"
#   $3 - "user" (default) or "system"
# Env:
#   $dotdeploy_modules
#   $DOTDEPLOY_DB
#   $DOTDEPLOY_LOCAL_DB
# Outputs:
#   None.
dd::files::process_phase_files() {
    local -n array_ref="$1"
    local action="${2:-copy}"
    local scope="${3:-user}"

    local key
    for key in "${!array_ref[@]}"; do
        local module
        for module in "${dotdeploy_modules[@]}"; do
            # Separate module from source file path
            IFS='|' read -r m source <<< "$key"
            if [[ $m == "$module" ]]; then
                if [[ $action == "copy" && $scope == "system" ]]; then
                    dd::files::copy_sys_file "$module" "$source" "${array_ref[$key]}"
                elif [[ $action == "link" && $scope == "system" ]]; then
                    dd::files::link_sys_file "$module" "$source" "${array_ref[$key]}"
                elif [[ $action == "copy" && $scope == "user" ]]; then
                    dd::files::copy_home_file "$module" "$source" "${array_ref[$key]}"
                elif [[ $action == "link" && $scope == "user" ]]; then
                    dd::files::link_home_file "$module" "$source" "${array_ref[$key]}"
                else
                    dd::log::log-fail "'action' needs to be either 'copy' or 'link' but is $action"
                    dd::log::log-fail "'scope' needs to be either 'user' or 'system' but is $scope"
                    exit 1
                fi
            fi
        done
    done
}

declare -A missing_sys_files
declare -A missing_home_files

# Collect missing files from DB
# Arguments:
#   $1 - Module
# Env:
#   $missing_sys_files
#   $missing_home_files
#   $DOTDEPLOY_DB
#   $DOTDEPLOY_LOCAL_DB
# Outputs:
#   None. Appends to missing files array.
dd::files::remove_missing() {
    local module="$1"
    local temp
    local source
    local target
    mapfile -t temp < <(dd::db::get_files "$DOTDEPLOY_DB" "$module")
    local f
    for f in "${temp[@]}"; do
        IFS='|' read -r source target <<< "$f"
        if [[ -n "$f" && ! -f "$source" ]]; then
            missing_sys_files["$module|$source"]="$target"
        fi
    done
    mapfile -t temp < <(dd::db::get_files "$DOTDEPLOY_LOCAL_DB" "$module")
    local f
    for f in "${temp[@]}"; do
        IFS='|' read -r source target <<< "$f"
        if [[ -n "$f" && ! -f "$source" ]]; then
            missing_home_files["$module|$source"]="$target"
        fi
    done
}


#
## File backups

DOTDEPLOY_BACKUPDIR="$DOTDEPLOY_ROOT"/backups
readonly DOTDEPLOY_BACKUPDIR
DOTDEPLOY_LOCAL_BACKUPDIR="$XDG_DATA_HOME"/dotdeploy/backups
readonly DOTDEPLOY_LOCAL_BACKUPDIR
mkdir -p "$DOTDEPLOY_LOCAL_BACKUPDIR"

dd::files::backup_file() {
    local filename="$1"
    local scope="${2:-user}"

    # Generate a timestamp
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    # Prepend the timestamp to the original filename
    backup_filename="${timestamp}${filename//\//_}"

    if [[ $scope == "user" ]]; then
        dd::common::dry_run cp -v --archive "$filename" "$DOTDEPLOY_LOCAL_BACKUPDIR"/"$backup_filename"
    else
        dd::common::elevate_cmd cp -v --archive "$filename" "$DOTDEPLOY_BACKUPDIR"/"$backup_filename"
    fi
}


# Marker function to indicate files.sh has been fully sourced
dd::files::loaded() {
  return 0
}
