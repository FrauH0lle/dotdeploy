#!/usr/bin/env bash

# Short-circuit if init.sh has already been sourced
[[ $(type -t dd::init::loaded) == function ]] && return 0


source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/env.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/common.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/log.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/db.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/files.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/hooks.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/confgen.sh


# Marker function to indicate init.sh has been fully sourced
dd::init::loaded() {
  return 0
}
