#!/bin/bash

# ======================================================================
# SECTION: Initial Configuration Setup
# ======================================================================

# Folder with hosts profiles
FOCUSD_HOSTS_DIR="/etc/focusd/hosts_profiles"

# State management
FOCUSD_STATE_DIR="/var/lib/focusd"
FOCUSD_STATE_FILE="${FOCUSD_STATE_DIR}/unlock_state"

# Source state management functions
if [ ! -f "/usr/local/lib/focusd/state_manager.sh" ]; then
  echo "Error: focusd is not properly installed."
  echo "State manager library not found at /usr/local/lib/focusd/state_manager.sh"
  echo "Please run the installation script first."
  exit 1
fi

source "/usr/local/lib/focusd/state_manager.sh"

# ======================================================================
# SECTION: Commands used in the project
# ======================================================================

# Get user UID (used in notifications)
COMMAND_GET_UID=("id" "-u")

# Get DISPLAY from user's graphical session
COMMAND_GET_DISPLAY=("bash" "-c" "loginctl show-user \"\$1\" --property=Display --value")

# Send desktop notification via D-Bus (executed as target user)
# (Final environment assembly occurs in dispatch_notify function)
COMMAND_NOTIFY_SEND=("notify-send" "-i" "focusd" "Focusd")

# ======================================================================
# SECTION: Utilities (logs and validations)
# ======================================================================

echo_log_warning() {
  # Usage: echo_log_warning "TITLE" "message"
  local title="$1"
  local message="$2"
  >&2 echo "[WARN] ${title}: ${message}"
}

ensure_sudo_access() {
  if [ "$EUID" -ne 0 ]; then
    echo "This operation requires sudo privileges."
    exit 1
  fi
}


# ======================================================================
# SECTION: Main Functions (script handlers)
# ======================================================================

dispatch_notify() {
  local user="$1"
  local message="$2"

  if [ -z "$user" ]; then
    echo_log_warning "WARN" "Target user for notification not specified."
    return 0
  fi

  if [ "$user" = "gdm" ]; then
    echo_log_warning "WARN" "User '$user' is a GNOME Display Manager user and can't receive notification."
    return 0
  fi

  # User UID
  local uid
  if ! uid=$("${COMMAND_GET_UID[@]}" "$user"); then
    echo_log_warning "WARN" "Failed to get UID for '$user'."
    return 0
  fi

  # DISPLAY from graphical session
  local display
  display=$(loginctl show-user "$user" --property=Display --value)

  # D-Bus session address
  local dbus_addr="/run/user/$uid/bus"

  # Send notification in user's session
  sudo -u "$user" DISPLAY="$display" DBUS_SESSION_BUS_ADDRESS="unix:path=$dbus_addr" \
    "${COMMAND_NOTIFY_SEND[@]}" "$message" >/dev/null 2>&1 || true
}

unlock_conditionally_blocked() {
  ensure_sudo_access
  
  local duration="${1:-300}"
  
  # Validate duration (max 10 minutes = 600 seconds)
  if ! [[ "$duration" =~ ^[0-9]+$ ]] || [ "$duration" -gt 600 ] || [ "$duration" -lt 60 ]; then
    echo "Error: Duration must be a number between 60 and 600 seconds (1-10 minutes)"
    exit 1
  fi
  
  # Set unlocked state using state_manager function
  set_unlocked "$duration" "all"
  
  # Apply unlocked hosts file
  local unlocked_hosts="$FOCUSD_HOSTS_DIR/hosts.unlocked"
  if [ -f "$unlocked_hosts" ]; then
    cp "$unlocked_hosts" "/etc/hosts"
    echo "✓ Conditionally blocked sites unlocked for $((duration / 60)) minutes"
    
    # Notify user
    local active_user
    active_user=$(who | grep '(:' | awk '{print $1}' | head -n1)
    if [ -n "$active_user" ]; then
      dispatch_notify "$active_user" "🔓 Temporary unlock active for $((duration / 60)) minutes. Stay focused!"
    fi
  else
    echo "Error: Unlocked hosts profile not found at $unlocked_hosts"
    exit 1
  fi
}

lock_conditionally_blocked() {
  ensure_sudo_access
  
  # Set locked state using state_manager function
  set_locked
  
  # Apply locked hosts file
  local locked_hosts="$FOCUSD_HOSTS_DIR/hosts.locked"
  if [ -f "$locked_hosts" ]; then
    cp "$locked_hosts" "/etc/hosts"
    echo "✓ Conditionally blocked sites are now locked"
    
    # Notify user
    local active_user
    active_user=$(who | grep '(:' | awk '{print $1}' | head -n1)
    if [ -n "$active_user" ]; then
      dispatch_notify "$active_user" "🔒 Focus mode re-enabled. All distracting sites blocked."
    fi
  else
    echo "Error: Locked hosts profile not found at $locked_hosts"
    exit 1
  fi
}

print_banner() {
  cat << 'EOF'
  __                          _  
 / _| ___   ___ _   _ ___  __| |
| |_ / _ \ / __| | | / __|/ _` |
|  _| (_) | (__| |_| \__ \ (_| |
|_|  \___/ \___|\__,_|___/\__,_|
                                
EOF
  echo ""
}

show_unlock_status() {
  print_banner
  
  if is_unlocked; then
    local time_remaining
    time_remaining=$(format_time_remaining)
    echo "Status: 🔓 UNLOCKED"
    echo "Time remaining: $time_remaining"
    echo "Always-blocked sites: BLOCKED"
    echo "Conditionally-blocked sites: ACCESSIBLE"
  else
    echo "Status: 🔒 LOCKED"
    echo "Always-blocked sites: BLOCKED"
    echo "Conditionally-blocked sites: BLOCKED"
  fi
  echo ""
  echo "Use 'sudo focusd unlock [seconds]' to temporarily unlock (default: 300s = 5min)"
  echo "Use 'sudo focusd lock' to immediately re-lock"
}

# ===============================================================================
# SECTION: Argument Processing (subcommands: unlock | lock | status)
# ===============================================================================

case "${1:-}" in
  unlock)
    unlock_conditionally_blocked "${2:-300}"
    ;;
  lock)
    lock_conditionally_blocked
    ;;
  status)
    show_unlock_status
    ;;
  *)
    show_unlock_status
    ;;
esac
