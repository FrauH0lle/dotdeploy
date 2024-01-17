#!/usr/bin/env bash

# Short-circuit if sync.sh has already been sourced
[[ $(type -t dd::sync::loaded) == function ]] && return 0


#
## Libraries
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/db.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/common.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/log.sh


# Print usage to stdout.
# Arguments:
#   None
# Outputs:
#   Print usage with examples.
dd::sync::help() {
    cat <<EOF
Check if deployed files are in sync with their sources.

Usage:

    dotdeploy check

Only copied files will be checked.

Options:
    help, -h, --help     Show this help message
EOF
}

# Collect copied files which not in sync with their source
# Arguments:
#   None
# Env:
#   $DOTDEPLOY_LOCAL_DB
#   $DOTDEPLOY_DB
# Outputs:
#   Files which are out of sync separated by \n.
dd::sync::collect() {
    local changed_files=()
    # Collect deployed modules
    local all_modules
    mapfile -t all_modules < <(dd::db::get_modules)

    local module
    for module in "${all_modules[@]}"; do
      mapfile -t temp1 < <(dd::db::get_copied_files "$DOTDEPLOY_DB" "$module")
      mapfile -t temp2 < <(dd::db::get_copied_files "$DOTDEPLOY_LOCAL_DB" "$module")
      local all_files
      mapfile -t all_files < <(dd::common::arr_remove_duplicates "${temp1[@]}" "${temp2[@]}")

      if [[ "${#all_files[@]}" -gt 0 ]]; then
        local f
        for f in "${all_files[@]}"; do
          if [[ -n "$f" ]]; then

            local source
            local dest
            IFS='|' read -r source dest <<< "$f"

            local source_checksum
            local dest_checksum
            source_checksum=$(dd::db::get_checksum "$DOTDEPLOY_DB" "$module" "$source")
            if [[ -z "$source_checksum" ]]; then
              source_checksum=$(dd::db::get_checksum "$DOTDEPLOY_LOCAL_DB" "$module" "$source")
            fi
            dest_checksum=$(sha256sum "$dest" | cut -d ' ' -f 1)
            if [[ $dest_checksum != "$source_checksum" ]]; then
              changed_files+=( "$module|$f" )
            fi
          fi
        done
      fi
    done

    if [[ "${#changed_files[@]}" -gt 0 ]]; then
      printf "%s\n" "${changed_files[@]}"
    fi
}

# Check if deployed files are in sync with their sources
# Arguments:
#   None
# Env:
#   $DOTDEPLOY_LOCAL_DB
#   $DOTDEPLOY_DB
# Outputs:
#   None. Will report files which are out of sync.
dd::sync::check() {
    while (( $# > 0 )) ; do
      case $1 in
      help | --help | -h)
          # Deactivate logging
          dd::log::log_off
          dd::sync::help
          exit 0
          ;;
      --)
          shift
          break
          ;;
      -*)
          printf >&2 "Error: Unknown option %s\n" "$1"
          dd::log::log_off
          dd::sync::help
          exit 1
          ;;
      *)  # Default case: Error
          printf >&2 "Error: Unknown option %s\n" "$1"
          dd::log::log_off
          dd::sync::help
          exit 1
          ;;
      esac
      # Shift to next argument
      shift
    done

    # Collect files which have changed
    local changed_files
    mapfile -t changed_files < <(dd::sync::collect)

    if [[ "${#changed_files[@]}" -gt 0 ]]; then
      local file
      for file in "${changed_files[@]}"; do

        local source
        local dest
        IFS='|' read -r module source dest <<< "$file"

        dd::log::log-warn "$dest has diverted from its source!"
        printf '\n'
        git --no-pager diff --color --no-index "$source" "$dest" || true
        printf '\n'

        while true; do
          echo "Which file should be kept?"
          echo "a) $source"
          echo "b) $dest"
          echo "s) Skip"

          read -rp "Select an option: " choice

          case "$choice" in
          a)
              echo "Option 'a' selected."
              dd::log::log-ok "Keeping $source"
              if [[ "$dest" =~ ^"$HOME" ]]; then
                dd::common::dry_run mkdir -p "$(dirname "$dest")"
                dd::common::dry_run cp "$source" "$dest"
              else
                dd::common::elevate_cmd mkdir -p "$(dirname "$dest")"
                dd::common::elevate_cmd cp "$source" "$dest"
              fi
              break
              ;;
          b)
              echo "Option 'b' selected."
              dd::log::log-ok "Keeping $dest"
              dd::common::dry_run cp "$dest" "$source"
              if [[ "$dest" =~ ^"$HOME" ]]; then
                dd::db::delete_file "$DOTDEPLOY_LOCAL_DB" "$module" "$source"
                dd::db::add_file "$DOTDEPLOY_LOCAL_DB" "$module" "$source" "$dest" "copy" "$(sha256sum "$dest" | cut -d ' ' -f 1)"
              else
                dd::db::delete_file "$DOTDEPLOY_DB" "$module" "$source"
                dd::db::add_file "$DOTDEPLOY_DB" "$module" "$source" "$dest" "copy" "$(sha256sum "$dest" | cut -d ' ' -f 1)"
              fi
              break
              ;;
          s)
              echo "Skipping."
              break
              ;;
          *)
              echo "Wrong option. Please choose 'a', 'b', or 's'."
              ;;
          esac
        done
      done
    fi
}


# Marker function to indicate sync.sh has been fully sourced
dd::sync::loaded() {
    return 0
}
