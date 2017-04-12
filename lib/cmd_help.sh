#!/bin/bash

BASE=$(dirname $(readlink -f "$0"))
source "$BASE/lib_cmd.sh"
source "$BASE/lib_msg.sh"

usage_help() {
  cat << EOF
usage: hcm <command> [<args>]

Available commands:

   install        Install config module(s) in HOME directory
   remove-legacy  Remove the legacy files that hcm installed in the HOME
                  directory
   help           Show this doc

See 'hcm help <command>' to read about a specific subcommand.
EOF
}

usage_install() {
  cat << EOF
usage: hcm install [<dir>...] [--[no-]fast-scan]

Current PWD will be used if <dir> is omitted.

If <dir> is a Managed Configs Directory (MCD), all of CMs inside will be installed.
If <dir> is a Config Module (CM), only this CM will be installed.

OPTIONS
       --fast-scan (DEFAULT)
           Skip the directory without modification. (based on timestamp)

       --no-fast-scan
           Do full scan.

EOF
}

usage_remove_legacy() {
  cat << EOF
usage: hcm remove-legacy [--[no-]fast-scan]


OPTIONS
       --fast-scan
           only scan the files and directories mentioned in the tracking directory.

       --no-fast-scan (DEFAULT)
           scan the whole HOME directory.

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
