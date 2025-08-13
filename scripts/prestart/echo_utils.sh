#!/bin/bash

set -e

# ------------------------------------------------------------------------------
# Echo helpers with colors and symbols for logging and user feedback
# ------------------------------------------------------------------------------

# Success (green with ✓ symbol)
# Usage: echo_success "Operation completed"
echo_success(){
    local message="$1"
    echo -e "\e[32m✓\e[0m $message"
}

# Error (red with ✗ symbol, prints to stderr and exits)
# Usage: echo_error "Something went wrong"
echo_error(){
    local message="$1"
    echo -e "\e[31m✗\e[0m $message" >&2
    exit 1
}

# Warning (yellow with ⚠ symbol)
# Usage: echo_warn "This action might be unsafe"
echo_warn(){
    local message="$1"
    echo -e "\e[33m⚠\e[0m $message"
}

# Info (blue with ℹ symbol)
# Usage: echo_info "Starting process"
echo_info(){
    local message="$1"
    echo -e "\e[34mℹ\e[0m $message"
}

# Section header (bold with border)
# Usage: echo_header "User Setup"
echo_header() {
  local msg="$*"
  local cols
  cols=$(tput cols 2>/dev/null) || cols=${COLUMNS:-80}
  (( cols < 20 )) && cols=80

  # Linha de borda (========...)
  local border
  border=$(printf '%*s' "$cols" '')           # preenche com espaços
  border=${border// /=}                       # troca espaços por '='

  printf '%s\n' "$border"

  # Mensagem centralizada
  local inner=" $msg "
  local len=${#inner}
  if (( len >= cols )); then
    printf '%s\n' "$inner"
  else
    local left=$(( (cols - len) / 2 ))
    local right=$(( cols - len - left ))
    printf '%*s%s%*s\n' "$left" '' "$inner" "$right" ''
  fi

  printf '%s\n' "$border"
}