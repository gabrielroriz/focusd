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
readonly FOCUSD_CONFIG_FILE="${FOCUSD_CONFIG_DIR}/focusd.conf"
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

readonly HOSTS_RESTRICTED_FILE="${SCRIPT_DIR}/../hosts/hosts.restricted"
readonly HOSTS_DEFAULT_FILE="${SCRIPT_DIR}/../hosts/hosts.default"
readonly HOSTS_BASE_FILE="${SCRIPT_DIR}/../hosts/hosts.base"
readonly HOSTS_NO_SOCIAL_FILE="${SCRIPT_DIR}/../hosts/hosts.no_social"
readonly HOSTS_BACKUP_FILE="/etc/hosts.backup"

readonly DOMAINS_DOPAMINE="${SCRIPT_DIR}/../domains/domain-list-dopamine.txt"
readonly DOMAINS_ADULTS="${SCRIPT_DIR}/../domains/domain-list-adults.txt"
readonly DOMAINS_SOCIAL_MEDIA="${SCRIPT_DIR}/../domains/domain-list-social-media.txt"
readonly DOMAINS_SOCIAL_MEDIA_LIGHT="${SCRIPT_DIR}/../domains/domain-list-social-media-light.txt"


# ------------------------------------------------------------------------------
# CLI Configuration
# ------------------------------------------------------------------------------
readonly FOCUSD_CLI_SCRIPT="${SCRIPT_DIR}/cli/focusd_cli_script.sh"
readonly FOCUSD_CLI_BIN="/usr/local/bin/focusd"