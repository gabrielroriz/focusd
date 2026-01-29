#!/bin/bash
set -e

# -----------------------------------------------------------------------
# Base Directory (directory of this script)
# -----------------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -----------------------------------------------------------------------
# Prestart Utilities
# -----------------------------------------------------------------------
source "${SCRIPT_DIR}/prestart/constants.sh"
source "${SCRIPT_DIR}/prestart/echo_utils.sh"

# -----------------------------------------------------------------------
# User Setup
# -----------------------------------------------------------------------
echo_header "User Setup"
source "${SCRIPT_DIR}/user/prestart.sh"
source "${SCRIPT_DIR}/user/config_xprofile.sh"
source "${SCRIPT_DIR}/user/create_group.sh"
source "${SCRIPT_DIR}/user/create_user.sh"

# -----------------------------------------------------------------------
# Config Setup
# -----------------------------------------------------------------------
echo_header "Config Setup"
source "${SCRIPT_DIR}/config/create_config.sh"

# -----------------------------------------------------------------------
# Hosts Setup
# -----------------------------------------------------------------------
echo_header "Hosts Setup"
source "${SCRIPT_DIR}/hosts/prestart.sh"
source "${SCRIPT_DIR}/hosts/create_hosts_backup.sh"
source "${SCRIPT_DIR}/hosts/generate_hosts_dynamic.sh"
generate_all_hosts_profiles
source "${SCRIPT_DIR}/hosts/update_etc_hosts.sh"

# -----------------------------------------------------------------------
# State Setup
# -----------------------------------------------------------------------
echo_header "State Setup"
source "${SCRIPT_DIR}/state/state_manager.sh"
init_unlock_state

# -----------------------------------------------------------------------
# Systemd Setup
# -----------------------------------------------------------------------
echo_header "Systemd Setup"
source "${SCRIPT_DIR}/systemd/install_icon.sh"
source "${SCRIPT_DIR}/systemd/install_script.sh"
source "${SCRIPT_DIR}/systemd/create_log.sh"
source "${SCRIPT_DIR}/systemd/run_service.sh"

# -----------------------------------------------------------------------
# CLI Setup
# -----------------------------------------------------------------------
echo_header "CLI Setup"
source "${SCRIPT_DIR}/cli/install_cli.sh"