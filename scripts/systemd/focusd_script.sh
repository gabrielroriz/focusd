#!/bin/bash

LOG_FILE="/var/log/focusd.log"

exec >> "$LOG_FILE" 2>&1

# Estilo para negrito
BOLD='\e[1m'
RESET='\e[0m'

# Verde com ✓
echo_log_success() {
    local title="$1"
    local message="$2"
    echo -e "- [$(date)] \e[32m✓${RESET} ${BOLD}${title}${RESET}: ${message}"
}

# Amarelo com ⚠
echo_log_warning() {
    local title="$1"
    local message="$2"
    echo -e "- [$(date)] \e[33m⚠${RESET} ${BOLD}${title}${RESET}: ${message}"
}

# Azul com ℹ
echo_log_info() {
    local title="$1"
    local message="$2"
    echo -e "- [$(date)] \e[34mℹ${RESET} ${BOLD}${title}${RESET}: ${message}"
}

# Vermelho com ✗
echo_log_error() {
    local title="$1"
    local message="$2"
    echo -e "- [$(date)] \e[31m✗${RESET} ${BOLD}${title}${RESET}: ${message}" >&2
}

# Vermelho com ✗ e termina o script
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
# Function to dispatch gui notification through dbus
# ------------------------------------------------------------------------------

dispatch_notify() {
  local user="$1"
  local message="$2"

  if [ "$user" = "gdm" ]; then
    echo_log_warning "WARN" "User '$user' is a GNOME Display Manager user and can't receive notification."
    return 0
  fi

  # Obtém UID do usuário
  local uid
  uid=$(id -u "$user") || return 1

  # Determina o DISPLAY (buscando na sessão gráfica)
  local display
  display=$(loginctl show-user "$user" --property=Display --value)

  # Caminho do D-Bus
  local dbus_addr="/run/user/$uid/bus"

  # Envia a notificação
  sudo -u "$user" DISPLAY="$display" DBUS_SESSION_BUS_ADDRESS="unix:path=$dbus_addr" \
    notify-send -i focusd "Focusd" "$message"
}

# ------------------------------------------------------------------------------
# Function to update /etc/hosts based on user's group membership
# ------------------------------------------------------------------------------

update_hosts() {
  local USERNAME="$1"
  local TARGET_GROUP="deep-group"

  local RESTRICTED_HOSTS="/etc/hosts.restricted"
  local DEFAULT_HOSTS="/etc/hosts.default"
  local TARGET_HOSTS="/etc/hosts"

  if id -nG "$USERNAME" | grep -qw "$TARGET_GROUP"; then
    echo_log_success "HOSTS UPDATED" "User '$USERNAME' belongs to group $TARGET_GROUP. Applying restricted hosts."
    cp "$RESTRICTED_HOSTS" "$TARGET_HOSTS"
    dispatch_notify "$USERNAME" "Access to external sites has been restricted ($(get_filename "$RESTRICTED_HOSTS"))."
  else
    echo_log_success "HOSTS UPDATED" "User '$USERNAME' does NOT belong to group $TARGET_GROUP. Applying default hosts."
    cp "$DEFAULT_HOSTS" "$TARGET_HOSTS"
    dispatch_notify "$USERNAME" "Access to external sites has been restored ($(get_filename "$DEFAULT_HOSTS"))."
  fi
}

last_section="unknown"

while true; do
  # Captura a primeira sessão ativa encontrada (formato: ID|user)
  session_info=$(loginctl list-sessions --no-legend | while read -r session uid user seat tty; do
    if [[ $(loginctl show-session "$session" -p Active --value) == "yes" ]]; then
      echo "$session|$user"
      break
    fi
  done)

  # Extrai ID da sessão e nome do usuário a partir da string retornada
  current_section=$(cut -d'|' -f1 <<< "$session_info")
  current_user=$(cut -d'|' -f2 <<< "$session_info")

  # Verifica se houve mudança de sessão ativa
  if [[ "$current_section" != "$last_section" && -n "$current_section" ]]; then
    echo_log_info "NEW SESSION" "Session: $current_section | Última seção: $last_section"
    dispatch_notify "$current_user" "Nova seção identificada."
    update_hosts "$current_user"
  fi

  # Atualiza o valor da última sessão conhecida
  last_section="$current_section"
  sleep 2
done
