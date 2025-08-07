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
