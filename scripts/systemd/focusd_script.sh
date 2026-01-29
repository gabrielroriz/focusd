#!/bin/bash

LOG_FILE="/var/log/focusd.log"

exec >> "$LOG_FILE" 2>&1

# ------------------------------------------------------------------------------
# Source state management functions
# ------------------------------------------------------------------------------
FOCUSD_STATE_DIR="/var/lib/focusd"
FOCUSD_STATE_FILE="${FOCUSD_STATE_DIR}/unlock_state"

if [ ! -f "/usr/local/lib/focusd/state_manager.sh" ]; then
    echo "[ERROR] State manager library not found at /usr/local/lib/focusd/state_manager.sh"
    echo "[ERROR] Focusd is not properly installed. Exiting."
    exit 1
fi

source "/usr/local/lib/focusd/state_manager.sh"

# Bold style
BOLD='\e[1m'
RESET='\e[0m'

# Green with ✓
echo_log_success() {
    local title="$1"
    local message="$2"
    echo -e "- [$(date)] \e[32m✓${RESET} ${BOLD}${title}${RESET}: ${message}"
}

# Yellow with ⚠
echo_log_warning() {
    local title="$1"
    local message="$2"
    echo -e "- [$(date)] \e[33m⚠${RESET} ${BOLD}${title}${RESET}: ${message}"
}

# Blue with ℹ
echo_log_info() {
    local title="$1"
    local message="$2"
    echo -e "- [$(date)] \e[34mℹ${RESET} ${BOLD}${title}${RESET}: ${message}"
}

# Red with ✗
echo_log_error() {
    local title="$1"
    local message="$2"
    echo -e "- [$(date)] \e[31m✗${RESET} ${BOLD}${title}${RESET}: ${message}" >&2
}

# Red with ✗ and terminates the script
echo_log_fatal() {
    local title="$1"
    local message="$2"
    echo -e "- [$(date)] \e[31m✗${RESET} ${BOLD}${title}${RESET}: ${message}" >&2
    exit 1
}

echo_log_info "STARTED" "Script started by: $(whoami) (UID: $(id -u)) on host: $(hostname)"

# ------------------------------------------------------------------------------
# Function: Extract filename from full path
# ------------------------------------------------------------------------------
get_filename() {
  local path="$1"
  local filename
  filename=$(basename "$path")
  echo "$filename"
}

# ------------------------------------------------------------------------------
# Function to dispatch GUI notification through dbus
# ------------------------------------------------------------------------------

dispatch_notify() {
  local user="$1"
  local message="$2"

  if [ "$user" = "gdm" ]; then
    echo_log_warning "WARN" "User '$user' is a GNOME Display Manager user and can't receive notification."
    return 0
  fi

  # Get user's UID
  local uid
  uid=$(id -u "$user") || return 1

  # Determine DISPLAY (searching in graphical session)
  local display
  display=$(loginctl show-user "$user" --property=Display --value)

  # D-Bus path
  local dbus_addr="/run/user/$uid/bus"

  # Send the notification
  sudo -u "$user" DISPLAY="$display" DBUS_SESSION_BUS_ADDRESS="unix:path=$dbus_addr" \
    notify-send -i focusd "Focusd" "$message"
}

update_focusd_conf(){
  local new_mode="$1"

  if [[ "$new_mode" != "default" && "$new_mode" != "restricted" && "$new_mode" != "locked" && "$new_mode" != "unlocked" ]]; then
    echo_log_warning "CONFIG" "Invalid mode '$new_mode'. Use 'default', 'restricted', 'locked' or 'unlocked'."
    return 1
  fi

  # Update configuration file
  if grep -qE '^mode=' /etc/focusd/focusd.conf; then
    sed -i "s/^mode=.*/mode=$new_mode/" /etc/focusd/focusd.conf
  else
    echo "mode=$new_mode" >> /etc/focusd/focusd.conf
  fi

  echo_log_success "CONFIG" "Mode updated to '$new_mode'."
}

# ------------------------------------------------------------------------------
# Function to check and handle unlock expiry
# ------------------------------------------------------------------------------

check_unlock_expiry() {
  local USERNAME="$1"
  
  if ! is_unlocked; then
    return 0  # Not unlocked, nothing to check
  fi
  
  local timestamp duration expiry now remaining
  timestamp=$(get_state_value "UNLOCK_TIMESTAMP" "0")
  duration=$(get_state_value "UNLOCK_DURATION" "300")
  expiry=$((timestamp + duration))
  now=$(date +%s)
  remaining=$((expiry - now))
  
  # Check if expired
  if [ $now -ge $expiry ]; then
    echo_log_warning "UNLOCK EXPIRED" "Temporary unlock period has ended. Re-locking conditionally blocked sites."
    set_locked
    update_hosts "$USERNAME"
    dispatch_notify "$USERNAME" "🔒 Focus mode re-enabled. Conditionally blocked sites are now restricted."
    return 0
  fi
  
  # Check for 60 second warning
  if [ $remaining -le 60 ] && [ $remaining -gt 58 ]; then
    local minutes=$((remaining / 60))
    local seconds=$((remaining % 60))
    dispatch_notify "$USERNAME" "⚠️  Warning: 1 minute until sites are blocked again."
  fi
}

# ------------------------------------------------------------------------------
# Function to update /etc/hosts based on user's group membership and unlock state
# ------------------------------------------------------------------------------

update_hosts() {
  local USERNAME="$1"
  local TARGET_GROUP="deep-group"

  local LOCKED_HOSTS="/etc/focusd/hosts_profiles/hosts.locked"
  local UNLOCKED_HOSTS="/etc/focusd/hosts_profiles/hosts.unlocked"
  
  local TARGET_HOSTS="/etc/hosts"

  # Check unlock state first
  if is_unlocked; then
    echo_log_success "HOSTS UPDATED" "Unlocked state active. Applying unlocked hosts (only always-blocked)."
    cp "$UNLOCKED_HOSTS" "$TARGET_HOSTS" 2>/dev/null || cp "$LOCKED_HOSTS" "$TARGET_HOSTS"
    return 0
  fi

  # Check group membership for locked state
  if id -nG "$USERNAME" | grep -qw "$TARGET_GROUP"; then
    echo_log_success "HOSTS UPDATED" "User '$USERNAME' in $TARGET_GROUP. Applying full blocking (locked)."
    cp "$LOCKED_HOSTS" "$TARGET_HOSTS" 2>/dev/null || echo_log_error "ERROR" "Could not find $LOCKED_HOSTS"
    dispatch_notify "$USERNAME" "🔒 Full focus mode active. All distracting sites blocked."
  else
    echo_log_success "HOSTS UPDATED" "User '$USERNAME' NOT in $TARGET_GROUP. Applying full blocking (locked)."
    cp "$LOCKED_HOSTS" "$TARGET_HOSTS" 2>/dev/null || echo_log_error "ERROR" "Could not find $LOCKED_HOSTS"
    dispatch_notify "$USERNAME" "🔒 Focus mode active. Distracting sites are blocked."
  fi
}

last_section=""
last_user=""

while true; do
  # Capture the first active session found (format: ID|user)
  session_info=$(loginctl list-sessions --no-legend | while read -r session uid user seat tty; do
    if [[ $(loginctl show-session "$session" -p Active --value) == "yes" ]]; then
      echo "$session|$user"
      break
    fi
  done)

  # Extract session ID and username from the returned string
  current_section=$(cut -d'|' -f1 <<< "$session_info")
  current_user=$(cut -d'|' -f2 <<< "$session_info")

  # Check if there was a real change in the active session (session ID or user changed)
  if [[ "$current_section" != "$last_section" && -n "$current_section" && -n "$last_section" ]]; then
    echo_log_info "SESSION CHANGE" "Session changed: $last_section → $current_section (User: $current_user)"
    dispatch_notify "$current_user" "Focus mode active for new session."
    update_hosts "$current_user"
  elif [[ -z "$last_section" && -n "$current_section" ]]; then
    # First time detecting session after service start
    echo_log_info "SESSION DETECTED" "Initial session: $current_section (User: $current_user)"
    update_hosts "$current_user"
  fi

  # Check unlock expiry for current user
  if [[ -n "$current_user" ]]; then
    check_unlock_expiry "$current_user"
  fi

  # Update the value of the last known session
  last_section="$current_section"
  last_user="$current_user"
  sleep 2
done
