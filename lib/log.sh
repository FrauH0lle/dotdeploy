#!/usr/bin/env bash

# Short-circuit if log.sh has already been sourced
[[ $(type -t dd::log::loaded) == function ]] && return 0


# Expected system env variables:
# XDG_DATA_HOME
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/env.sh


#
## Prettier messages

# Print info message
# Arguments:
#   $*: Message string
# Outputs:
#   Message string, prefixed with '+++' in blue and bold
function dd::log::log-info() {
    printf "\r\033[2K\033[1;34m +++ \033[0m%s\n" "$*"
}

# Print success message
# Arguments:
#   $*: Message string
# Outputs:
#   Message string, prefixed with '+++' in green and bold
function dd::log::log-ok() {
    printf "\r\033[2K\033[1;32m +++ \033[0m%s\n" "$*"
}

# Print warning message
# Arguments:
#   $*: Message string
# Outputs:
#   Message string, prefixed with '+++' in yellow and bold
function dd::log::log-warn() {
    printf "\r\033[2K\033[1;33m +++ \033[0m%s\n" "$*"
}

# Print failure message
# Arguments:
#   $*: Message string
# Outputs:
#   Message string, prefixed with '+++' in red and bold
function dd::log::log-fail() {
    printf "\r\033[2K\033[1;31m +++ \033[0m%s\n" "$*"
}


#
## Log file

# Based on https://serverfault.com/a/103569

dotdeploy_logdir="$XDG_DATA_HOME/dotdeploy/logs"
# Create log directory if it does not exist
mkdir -p "$dotdeploy_logdir"

# Generate logfile name with timestamp
timestamp=$(date "+%Y-%m-%d_%H-%M-%S")
dotdeploy_logfile="${dotdeploy_logdir}/log_${timestamp}.txt"

# Redirect file descriptors and stdout/stderr to logfile
# Arguments:
#   None
# Env:
#   $dotdeploy_logfile
# Outputs:
#   None
# Based on https://stackoverflow.com/a/72171285/22738667
dd::log::log_on() {
    # Setup file descriptor redirection
    # 1) make file descriptor 3 a copy of stdout
    # 2) make file descriptor 4 a copy of stderr
    # 3) redirect-append stdout to file $dotdeploy_logfile
    # 4) make stderr a copy of stdout
    exec 3>&1 4>&2 1> >(tee -a "$dotdeploy_logfile") 2>&1
}

# Restore file descriptors and rotate log
# Arguments:
#   None
# Outputs:
#   None
dd::log::log_off() {
    # Restore file descriptors for 1 and 2
    exec 1>&3 2>&4
}

# Rotate logs and keep last 20 log files
# Arguments:
#   None
# Env:
#   $dotdeploy_logfile
#   $dotdeploy_logdir
# Outputs:
#   None
dd::log::rotate_logs() {
    # Deactivate logging
    dd::log::log_off

    # Check if log file has any content and remove otherwise
    [[ -s "$dotdeploy_logfile" ]] || rm "$dotdeploy_logfile"

    # Strip ANSI escape sequences
    sed -i "s/\x1B\[[0-9;]\{1,\}[A-Za-z]//g" "$dotdeploy_logfile"

    # Log rotation: Keep only the last 20 log files
    find "$dotdeploy_logdir" -name 'log_*.txt' -type f | sort -r | tail -n +21 | xargs rm -- > /dev/null 2>&1
}

# Trap signals to ensure cleanup function gets executed on script exit
trap dd::log::rotate_logs EXIT


#
## Module info messages

DOTDEPLOY_MESSAGES_FILE=$(mktemp --tmpdir="$DOTDEPLOY_TMP_DIR" --suffix .sh)

# Initialize messages file
# Arguments:
#   None
# Env:
#   $DOTDEPLOY_MESSAGES_FILE
# Outputs:
#   None. Writes to $DOTDEPLOY_MESSAGES_FILE.
dd::log::init_messages() {
    { echo "#!/usr/bin/env bash"; } > "$DOTDEPLOY_MESSAGES_FILE"
}

# Store messages.
# Define variables in file with expansion, last to sections get inserted
# verbatim.
# Arguments:
#   $1 - Module
#   $2 - Message
# Env:
#   $DOTDEPLOY_MESSAGES_FILE
# Outputs:
#   None. Writes to $DOTDEPLOY_MESSAGES_FILE.
dd::log::store_messages() {
    {
        cat <<EOF
module="$1"
message="$2"
EOF

        cat <<'EOF'
dd::log::log-warn "Information for $module:"
EOF

        cat <<'EOF'
echo
echo "$message"
echo
EOF
    } >> "$DOTDEPLOY_MESSAGES_FILE"
}

# Display messages
dd::log::display_messages() {
    source "$DOTDEPLOY_MESSAGES_FILE"
}


# Marker function to indicate log.sh has been fully sourced
dd::log::loaded() {
  return 0
}
