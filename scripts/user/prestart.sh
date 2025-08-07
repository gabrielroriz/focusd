#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# Definition of utility functions
# ------------------------------------------------------------------------------

get_group_id(){
    local group_name="$1"
    grep "^${group_name}:" /etc/group | cut -d: -f3 # delimitador "-d:"; terceiro item "f3".
}

get_user_id(){
    local user_name="$1"
    grep "^${user_name}:" /etc/passwd | cut -d: -f3 # delimitador "-d:"; terceiro item "f3".
}
