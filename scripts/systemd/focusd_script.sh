#!/bin/bash

LOG_FILE="/var/log/focusd.log"

exec >> "$LOG_FILE" 2>&1

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

echo_log_info "STARTED" "Script iniciado por: $(whoami) (UID: $(id -u)) no host: $(hostname)"

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

  if [[ "$new_mode" != "default" && "$new_mode" != "restricted" ]]; then
    echo_log_warning "CONFIG" "Modo inválido '$new_mode'. Use 'default' ou 'restricted'."
    return 1
  fi

  # Atualiza o arquivo de configuração
  if grep -qE '^mode=' /etc/focusd/focusd.conf; then
    sed -i "s/^mode=.*/mode=$new_mode/" /etc/focusd/focusd.conf
  else
    echo "mode=$new_mode" >> /etc/focusd/focusd.conf
  fi

  echo_log_success "CONFIG" "Modo atualizado para '$new_mode'."
}

# ------------------------------------------------------------------------------
# Function to update /etc/hosts based on user's group membership
# ------------------------------------------------------------------------------

update_hosts() {
  local USERNAME="$1"
  local TARGET_GROUP="deep-group"

  local RESTRICTED_HOSTS="/etc/focusd/hosts_profiles/hosts.restricted"
  local DEFAULT_HOSTS="/etc/focusd/hosts_profiles/hosts.default"
  
  local TARGET_HOSTS="/etc/hosts"

  if id -nG "$USERNAME" | grep -qw "$TARGET_GROUP"; then
    echo_log_success "HOSTS UPDATED" "User '$USERNAME' belongs to group $TARGET_GROUP. Applying restricted hosts."
    cp "$RESTRICTED_HOSTS" "$TARGET_HOSTS"
    update_focusd_conf "restricted"
    dispatch_notify "$USERNAME" "Access to external sites has been restricted ($(get_filename "$RESTRICTED_HOSTS"))."
  else
    echo_log_success "HOSTS UPDATED" "User '$USERNAME' does NOT belong to group $TARGET_GROUP. Applying default hosts."
    cp "$DEFAULT_HOSTS" "$TARGET_HOSTS"
    update_focusd_conf "default"
    dispatch_notify "$USERNAME" "Access to external sites has been restored ($(get_filename "$DEFAULT_HOSTS"))."
  fi
}

last_section="unknown"

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

  # Check if there was a change in the active session
  if [[ "$current_section" != "$last_section" && -n "$current_section" ]]; then
    echo_log_info "NEW SESSION" "Session: $current_section | Last session: $last_section"
    dispatch_notify "$current_user" "New session identified ($current_section)."
    update_hosts "$current_user"
  fi

  # Update the value of the last known session
  last_section="$current_section"
  sleep 2
done
