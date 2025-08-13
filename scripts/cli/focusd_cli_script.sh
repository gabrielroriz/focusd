#!/bin/bash

# ======================================================================
# SEÇÃO: Setup inicial de configuração
# ======================================================================

# Arquivo de configuração do Focusd
FOCUSD_CONFIG_FILE="/etc/focusd/focusd.conf"

# Pasta com os perfis de hosts
FOCUSD_HOSTS_DIR="/etc/focusd/hosts_profiles"

# ======================================================================
# SEÇÃO: Comandos utilizados no projeto
# ======================================================================

# Lista arquivos "hosts.*" e remove o prefixo "hosts."
COMMAND_LIST_HOST_PROFILES=("bash" "-c" "ls \"$FOCUSD_HOSTS_DIR\" | sed 's/^hosts\\.//'")

# Obtém o UID do usuário (usado em notificações)
COMMAND_GET_UID=("id" "-u")

# Obtém o DISPLAY de uma sessão gráfica do usuário
COMMAND_GET_DISPLAY=("bash" "-c" "loginctl show-user \"\$1\" --property=Display --value")

# Envia notificação desktop via D-Bus (executado como o usuário alvo)
# (A montagem final dos envs ocorre na função dispatch_notify)
COMMAND_NOTIFY_SEND=("notify-send" "-i" "focusd" "Focusd")

# ======================================================================
# SEÇÃO: Variáveis de controle
# ======================================================================

selected_register=""

# ======================================================================
# SEÇÃO: Utilitários (logs e validações)
# ======================================================================

echo_log_warning() {
  # Uso: echo_log_warning "TÍTULO" "mensagem"
  local title="$1"
  local message="$2"
  >&2 echo "[WARN] ${title}: ${message}"
}

ensure_config_exists() {
  if [ ! -f "$FOCUSD_CONFIG_FILE" ]; then
    echo "Focusd configuration file not found: $FOCUSD_CONFIG_FILE"
    exit 1
  fi
}

ensure_hosts_dir_exists() {
  if [ ! -d "$FOCUSD_HOSTS_DIR" ]; then
    echo "Hosts profiles directory not found: $FOCUSD_HOSTS_DIR"
    exit 1
  fi
}

# ======================================================================
# SEÇÃO: Funções reutilizáveis de menu interativo
# ======================================================================

draw_menu() {
  local title="$1"
  shift
  local options=("$@")
  local options_size=$(( ${#options[@]} + 3 ))

  # Ajusta altura do terminal (opcional)
  printf "\e[8;%s;120t" "$options_size"

  local selected=0

  while true; do
    clear
    echo "$title"
    for i in "${!options[@]}"; do
      if [[ $i == $selected ]]; then
        printf "  > \e[1;32m%s\e[0m\n" "${options[$i]}"
      else
        printf "    %s\n" "${options[$i]}"
      fi
    done

    IFS= read -rsn1 key
    [[ $key == $'\x1b' ]] && read -rsn2 -t 0.01 key

    case "$key" in
      "[A") ((selected--)); [[ $selected -lt 0 ]] && selected=$((${#options[@]} - 1)) ;;
      "[B") ((selected++)); [[ $selected -ge ${#options[@]} ]] && selected=0 ;;
      "") break ;;
    esac
  done

  selected_register="${options[$selected]}"
}

# ======================================================================
# SEÇÃO: Funções principais (handlers do script)
# ======================================================================

dispatch_notify() {
  local user="$1"
  local message="$2"

  if [ -z "$user" ]; then
    echo_log_warning "WARN" "Usuário alvo para notificação não informado."
    return 0
  fi

  if [ "$user" = "gdm" ]; then
    echo_log_warning "WARN" "User '$user' is a GNOME Display Manager user and can't receive notification."
    return 0
  fi

  # UID do usuário
  local uid
  if ! uid=$("${COMMAND_GET_UID[@]}" "$user"); then
    echo_log_warning "WARN" "Falha ao obter UID de '$user'."
    return 0
  fi

  # DISPLAY da sessão gráfica
  local display
  display=$(loginctl show-user "$user" --property=Display --value)

  # Endereço do D-Bus da sessão
  local dbus_addr="/run/user/$uid/bus"

  # Envia notificação na sessão do usuário
  sudo -u "$user" DISPLAY="$display" DBUS_SESSION_BUS_ADDRESS="unix:path=$dbus_addr" \
    "${COMMAND_NOTIFY_SEND[@]}" "$message" >/dev/null 2>&1 || true
}

get_focusd_config() {
  ensure_config_exists
  cat "$FOCUSD_CONFIG_FILE"
}

set_focusd_config() {
  ensure_config_exists
  ensure_hosts_dir_exists

  # Carrega perfis disponíveis
  mapfile -t hosts_profiles < <("${COMMAND_LIST_HOST_PROFILES[@]}")

  if [ "${#hosts_profiles[@]}" -eq 0 ]; then
    echo "Nenhum perfil encontrado em: $FOCUSD_HOSTS_DIR"
    exit 1
  fi

  # Menu de seleção
  draw_menu "Selecione o perfil de hosts (use ↑ ↓ para navegar, Enter para confirmar):" "${hosts_profiles[@]}"

  # Aplica o perfil selecionado
  local src="$FOCUSD_HOSTS_DIR/hosts.$selected_register"
  if [ ! -f "$src" ]; then
    echo "Perfil inexistente: $src"
    exit 1
  fi

  echo "Setting focusd configuration..."
  cp "$src" "/etc/hosts"

  # Melhor esforço para notificar o usuário logado na sessão gráfica
  # (heurística simples com 'who'; ajuste conforme seu ambiente)
  local active_user
  active_user=$(who | grep '(:' | awk '{print $1}' | head -n1)
  dispatch_notify "$active_user" "New focusd configuration has been set (hosts.$selected_register)."

  sed -i "s/^mode=.*/mode=$selected_register/" "$FOCUSD_CONFIG_FILE"
  echo "Focusd configuration updated successfully."
}

# ======================================================================
# SEÇÃO: Processamento de argumentos (subcomandos: show | set)
# ======================================================================

case "${1:-}" in
  show)
    get_focusd_config
    ;;
  set)
    set_focusd_config
    ;;
  *)
    echo "Usage: $0 {show|set}"
    exit 1
    ;;
esac
