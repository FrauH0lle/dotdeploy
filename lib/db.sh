#!/usr/bin/env bash

# Short-circuit if db.sh has already been sourced
[[ $(type -t dd::db::loaded) == function ]] && return 0


#
## Libraries
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/env.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/common.sh


#
## Environment
DOTDEPLOY_DB="$DOTDEPLOY_ROOT"/dotdeploy-db.json
readonly DOTDEPLOY_DB
DOTDEPLOY_LOCAL_DB="$XDG_DATA_HOME"/dotdeploy/dotdeploy-db.json
readonly DOTDEPLOY_LOCAL_DB


# Ensure JSON database exists
# Arguments:
#   $1 - DB file path
# Outputs:
#   None.
dd::db::ensure_db_exists() {
    local db_path="$1"
    if [[ ! -f "$db_path" ]]; then
        jq -n '{modules: {}, dotdeploy: {}}' > "$db_path"
    elif [[ ! -s "$db_path" ]]; then
        jq -n '{modules: {}, dotdeploy: {}}' > "$db_path"
    fi
}

# Ensure both the local and global JSON databases exist
dd::db::ensure_db_exists "$DOTDEPLOY_LOCAL_DB"
dd::db::ensure_db_exists "$DOTDEPLOY_DB"


# Ensure module exists in JSON database
# Arguments:
#   $1 - Database file
#   $2 - Module
# Outputs:
#   None.
dd::db::ensure-module() {
    local db_file="$1"
    local module="$2"

    if [[ -f "$db_file" ]]; then
        if [[ "$(jq --arg key "$module" '.modules | has($key)' "$db_file")" == "false" ]]; then
            # Add entry if it does not exist
            # shellcheck disable=SC2016
            dd::common::jq_dry_run jq --arg key "$module" '.modules += {($key) : {files: []}}' "$db_file"
        fi
    fi
}

# Check if source file is in JSON database
# Arguments:
#   $1 - Module
#   $2 - Source file
#   $3 - Database file
# Outputs:
#   0 if file exists, 1 else.
dd::db::check_source_file() {
    local module="$1"
    local source="$2"
    local db_file="$3"

    if jq -e ".modules.\"$module\" // empty | .files[] | select(.source == \"$source\")" "$db_file" > /dev/null; then
        # Source file exists in the database
        return 0
    else
        # Source file does not exist
        return 1
    fi
}

# Retrieve file checksum from JSON database
# Arguments:
#   $1 - Database file
#   $2 - Module
#   $3 - Source file path
# Outputs:
#   Checksum string.
dd::db::get_checksum() {
    local db_file="$1"
    local module="$2"
    local source="$3"
    local db_checksum
    if dd::db::check_source_file "$module" "$source" "$db_file"; then
        db_checksum=$(jq -r ".modules.\"${module}\".files[] | select(.source == \"${source}\").checksum" "${db_file}")
        echo "$db_checksum"
    fi
}

# Retrieve deployed files
# Arguments:
#   $1 - Database file
#   $2 - Module
# Outputs:
#   Array of strings of the form SOURCE|DESTINATION
dd::db::get_files() {
    local files
    mapfile -t -d "\n" files < <(jq -r ".modules.\"${2}\" // empty | .files[] | .source + \"|\" + .target" "${1}")
    if [[ ${#files[@]} -gt 0 ]]; then
        echo -n "${files[@]}"
    fi
}

# Retrieve deployed source files of type copy
# Arguments:
#   $1 - Database file
#   $2 - Module
# Outputs:
#   Array of strings of the form SOURCE|DESTINATION
dd::db::get_copied_files() {
    local files
    mapfile -t -d "\n" files < <(jq -r ".modules.\"${2}\" // empty | .files[] | select(.type == \"copy\") | .source + \"|\" + .target" "${1}")
    if [[ ${#files[@]} -gt 0 ]]; then
        echo -n "${files[@]}"
    fi
}

# Retrieve deployed source files of type link
# Arguments:
#   $1 - Database file
#   $2 - Module
# Outputs:
#   Array of strings of the form SOURCE|DESTINATION
dd::db::get_linked_files() {
    local files
    mapfile -t -d "\n" files < <(jq -r ".modules.\"${2}\" // empty | .files[] | select(.type == \"link\") | .source + \"|\" + .target" "${1}")
    if [[ ${#files[@]} -gt 0 ]]; then
        echo -n "${files[@]}"
    fi
}

# Add file to JSON database in the corresponding module section.
# Arguments:
#   $1 - Database file
#   $2 - Module
#   $3 - Source file
#   $4 - Target file
#   $5 - Type, copy or symlink
#   $6 - Checksum
# Outputs:
#   None. Writes to database file.
dd::db::add_file() {
    local db_file="$1"
    local module="$2"
    local source="$3"
    local target="$4"
    local type="$5"
    local checksum="${6:-null}"

    dd::common::jq_dry_run jq --arg module "$module" \
        --arg source "$source" \
        --arg target "$target" \
        --arg type "$type" \
        --arg checksum "$checksum" \
        '
if $checksum == "null" then
.modules.[$module].files += [{source: $source, target: $target, type: $type, checksum: null}]
else
.modules.[$module].files += [{source: $source, target: $target, type: $type, checksum: $checksum}]
end
' "$db_file"
}

# Delete file from JSON database
# Arguments:
#   $1 - Database file
#   $2 - Module
#   $3 - Source file path
# Outputs:
#   None.
dd::db::delete_file() {
    local db_file="$1"
    local module="$2"
    local source="$3"
    dd::common::jq_dry_run jq "del(.modules.\"$module\".files[] | select(.source == \"$source\"))" \
        "$db_file"
}


# Add or update a key value pair to a module in the JSON database
# Arguments:
#   $1 - Database file
#   $2 - Module
#   $3 - Key
#   $4 - Value
# Outputs:
#   None.
dd::db::write_module_kv() {
    local db_file="$1"
    local module="$2"
    local key="$3"
    local value="$4"
    if [[ "$(jq --arg key "$module" '.modules | has($key)' "$db_file")" == "true" ]]; then
        dd::common::jq_dry_run jq --arg module "$module" \
            --arg key "$key" \
            --argjson value "$value" \
            '.modules[$module][$key] = $value' \
            "$db_file"
    fi
}

# Add or update a key value pair to a module in the JSON database if it does not
# exist
# Arguments:
#   $1 - Database file
#   $2 - Module
#   $3 - Key
#   $4 - Value
# Outputs:
#   None.
dd::db::write_module_kv_maybe() {
    local db_file="$1"
    local module="$2"
    local key="$3"
    local value="$4"
    if [[ "$(jq --arg key "$module" '.modules | has($key)' "$db_file")" == "true" ]]; then
        if [[ "$(jq --arg module "$module" --arg key "$key" '.modules[$module] | has($key)' "$db_file")" == "false" ]]; then
            dd::common::jq_dry_run jq --arg module "$module" \
                --arg key "$key" \
                --argjson value "$value" \
                '.modules[$module][$key] = $value' \
                "$db_file"
        fi
    fi
}

# Add or update a key value pair to the metadata section of the JSON database
# Arguments:
#   $1 - Database file
#   $2 - Key
#   $3 - Value
# Outputs:
#   None.
dd::db::write_meta_kv() {
    local db_file="$1"
    local key="$2"
    local value="$3"
    dd::common::jq_dry_run jq --arg key "$key" \
        --argjson value "$value" \
        '.dotdeploy[$key] = $value' \
        "$db_file"
}

# Retrieve deployed modules
# Arguments:
#   $1 - Database file
# Outputs:
#   Active modules.
dd::db::get_modules() {
    local home_modules
    local sys_modules
    mapfile -t home_modules < <(jq -r '.modules | map_values(select(.deployed == true)) | keys[]' "$DOTDEPLOY_LOCAL_DB")
    mapfile -t sys_modules < <(jq -r '.modules | map_values(select(.deployed == true)) | keys[]' "$DOTDEPLOY_DB")

    local modules
    mapfile -t modules < <(dd::common::arr_remove_duplicates "${home_modules[@]}" "${sys_modules[@]}")

    if [[ ${#modules[@]} -gt 0 ]]; then
        printf "%s\n" "${modules[@]}"
    fi
}


# Marker function to indicate db.sh has been fully sourced
dd::db::loaded() {
  return 0
}
