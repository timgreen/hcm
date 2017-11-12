#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_cmd.sh"
source "$BASE/lib_msg.sh"

usage_help() {
  cat << EOF
usage: hcm <command> [<args>]

Available commands:

   install        Install config module(s) in HOME directory
   housekeeping   Remove the dead links the HOME directory
   help           Show this doc

See 'hcm help <command>' to read about a specific subcommand.
EOF
}

usage_install() {
  cat << EOF
usage: hcm install

Install modules configured in '\$HOME/.hcm/config.yml'.

OPTIONS
       -n | --dry-run (DEFAULT)
           Dry run. Only print the actions will be executed.

       -f | --no-dry-run
           Actually install modules.

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

usage_uninstall() {
  cat << EOF
usage: hcm uninstall
EOF
}

print_usage() {
  local cmd="${1:-help}"
  local cmd_filename="$(cmd_to_filename $cmd)"

  if is_valid_cmd_name "$cmd" && [[ "$(type -t usage_$cmd_filename)" == "function" ]]; then
    usage_$cmd_filename
  else
    echo "Unknown command $(highlight "$cmd")"
    echo
    usage_help
    exit 1
  fi
}

print_usage "$1"
