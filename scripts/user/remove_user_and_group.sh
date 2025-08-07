#!/bin/bash
set -e

echo_info "Removing user and group..."

if id "$USER_NAME" &>/dev/null; then
  sudo userdel -r -f "$USER_NAME"
  echo_success "User $USER_NAME removed."
else
  echo_success "User $USER_NAME does not exist."
fi

if getent group "$GROUP_NAME" &>/dev/null; then
  sudo groupdel -f "$GROUP_NAME"
  echo_success "Group $GROUP_NAME removed."
else
  echo_success "Group $GROUP_NAME does not exist."
fi
