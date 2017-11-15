#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))

[ -z "$INIT_MSG" ] && source "$BASE/lib_msg.sh"
[ -z "$INIT_CMD" ] && source "$BASE/lib_cmd.sh"

usage_help() {
  cat << EOF
usage: hcm <command> [<args>]

Available commands:

   sync           Sync config module(s) to HOME directory
   housekeeping   Remove the dead links the HOME directory
   help           Show this doc

See 'hcm help <command>' to read about a specific subcommand.
EOF
}

usage_sync() {
  cat << EOF
usage: hcm sync

Sync modules configured in '\$HOME/.hcm/config.yml' to HOME directory.

OPTIONS
       -n | --dry-run (DEFAULT)
           Dry run. Only print the actions will be executed.

       -f | --no-dry-run
           Actually sync modules.

EOF
}

usage_housekeeping() {
  cat << EOF
usage: hcm housekeeping

Unlink dead softlinks from the HOME directory. Only go down 5 levels for now.

OPTIONS
       -n | --dry-run (DEFAULT)
           Dry run. Only print the actions will be executed.

       -f | --no-dry-run
           Actually cleanup HOME directory.

EOF
}

print_usage() {
  local cmd="${1:-help}"
  local cmd_filename="$(cmd_to_filename $cmd)"

  if is_valid_cmd_name "$cmd" && [[ "$(type -t usage_$cmd_filename)" == "function" ]]; then
    usage_$cmd_filename
  else
    echo "Unknown command $(msg::highlight "$cmd")"
    echo
    usage_help
    exit 1
  fi
}

print_usage "$1"
