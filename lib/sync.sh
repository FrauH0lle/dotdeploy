#!/usr/bin/env bash

source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/common.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/db.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/log.sh

dd::sync::check() {
  # Collect deployed modules
  local home_modules
  local sys_modules
  mapfile -t home_modules < <(dd::db::get_modules "$DOTDEPLOY_LOCAL_DB")
  mapfile -t sys_modules < <(dd::db::get_modules "$DOTDEPLOY_DB")
  local all_modules=("${home_modules[@]}" "${sys_modules[@]}")
  mapfile -t all_modules < <(dd::common::arr_remove_duplicates "${all_modules[@]}")
  
  local module
  for module in "${all_modules[@]}"; do
    mapfile -t temp1 < <(dd::db::get_copied_files "$DOTDEPLOY_DB" "$module")
    mapfile -t temp2 < <(dd::db::get_copied_files "$DOTDEPLOY_LOCAL_DB" "$module")
    local all_files=("${temp1[@]}" "${temp2[@]}")
    mapfile -t all_files < <(dd::common::arr_remove_duplicates "${all_files[@]}")
    
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

            dd::log::log-warn "Fuck! The destination file has changed!"
            printf '\n'
            if dd::common::check_callable bat; then
            git diff --no-index "$source" "$dest" | bat
            else
              git diff --no-index "$source" "$dest"
            fi
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
                dd::db::add_file "$DOTDEPLOY_LOCAL_DB" "$module" "$source" "$dest" "copy" "$dest_checksum"
                else
                  dd::db::delete_file "$DOTDEPLOY_DB" "$module" "$source"
                  dd::db::add_file "$DOTDEPLOY_DB" "$module" "$source" "$dest" "copy" "$dest_checksum"
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

          fi
        fi
      done
    fi
  done
}

dd::sync::check
