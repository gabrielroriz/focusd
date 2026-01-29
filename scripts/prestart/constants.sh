#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# User and Group Configuration
# ------------------------------------------------------------------------------

readonly GROUP_NAME="deep-group"
readonly USER_NAME="deep-worker"
readonly USER_FULL_NAME="Deep Worker"

# ------------------------------------------------------------------------------
# Focusd Configuration Folder
# ------------------------------------------------------------------------------

readonly FOCUSD_CONFIG_DIR="/etc/focusd"
readonly FOCUSD_CONFIG_HOSTS_DIR="${FOCUSD_CONFIG_DIR}/hosts_profiles"

# ------------------------------------------------------------------------------
# Service Configuration
# ------------------------------------------------------------------------------

readonly LOCAL_FILE_SH="${SCRIPT_DIR}/systemd/focusd_script.sh"
readonly NAME_FILE_SH="focusd.sh"
readonly SERVICE_NAME="focusd.service"
readonly SERVICE_LOCATION="${SCRIPT_DIR}/../services/"
readonly LOG="focusd.log"

# ------------------------------------------------------------------------------
# Icon Configuration
# ------------------------------------------------------------------------------

readonly ICON_SOURCE="${SCRIPT_DIR}/../assets/focusd_icon.svg"
readonly ICON_NAME="focusd.svg"
readonly ICON_TARGET_DIR="/usr/share/icons/hicolor/scalable/apps"
readonly ICON_TARGET_PATH="${ICON_TARGET_DIR}/${ICON_NAME}"

# ------------------------------------------------------------------------------
# Hosts Configuration
# ------------------------------------------------------------------------------

readonly HOSTS_BASE_FILE="${SCRIPT_DIR}/../hosts/hosts.base"
readonly HOSTS_BACKUP_FILE="/etc/hosts.backup"

# Domain directories for two-tier blocking system
readonly DOMAINS_ALWAYS_BLOCKED_DIR="${SCRIPT_DIR}/../domains/always-blocked"
readonly DOMAINS_CONDITIONALLY_BLOCKED_DIR="${SCRIPT_DIR}/../domains/conditionally-blocked"
readonly DOMAINS_WHITELISTED_DIR="${SCRIPT_DIR}/../domains/whitelisted"

# State directory for unlock management
readonly FOCUSD_STATE_DIR="/var/lib/focusd"
readonly FOCUSD_STATE_FILE="${FOCUSD_STATE_DIR}/unlock_state"


# ------------------------------------------------------------------------------
# CLI Configuration
# ------------------------------------------------------------------------------
readonly FOCUSD_CLI_SCRIPT="${SCRIPT_DIR}/cli/focusd_cli_script.sh"
readonly FOCUSD_CLI_BIN="/usr/local/bin/focusd"