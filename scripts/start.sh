#!/bin/bash
set -e

source "./prestart/constants.sh"
source "./prestart/echo_utils.sh"

source "./user/prestart.sh"
source "./user/config_xprofile.sh"
source "./user/create_group.sh"
source "./user/create_user.sh"

source "./hosts/prestart.sh"
source "./hosts/create_host_restricted.sh"
source "./hosts/update_etc_hosts.sh"

source "./systemd/install_icon.sh"
source "./systemd/install_script.sh"
source "./systemd/create_log.sh"
source "./systemd/run_service.sh"
