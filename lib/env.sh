#!/usr/bin/env bash

# Short-circuit if env.sh has already been sourced
[[ $(type -t dd::env::loaded) == function ]] && return 0

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

DOTDEPLOY_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
DOTDEPLOY_MODULES_DIR="$DOTDEPLOY_ROOT"/modules
DOTDEPLOY_HOSTS_DIR="$DOTDEPLOY_ROOT"/hosts


# Marker function to indicate files.sh has been fully sourced
dd::env::loaded() {
  return 0
}
